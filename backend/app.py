from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:rizz123*@localhost:5432/restaurant_db'
db = SQLAlchemy(app)

# Models
class Reservation(db.Model):
    __tablename__ = 'reservations'  # Corrected to match PostgreSQL table name
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    people = db.Column(db.Integer, nullable=False, default=1)
    phone = db.Column(db.String(20), unique=True, nullable=False)
    status = db.Column(db.String(20), default='pending')
    present = db.Column(db.String(3), default='no', nullable=False)
    reservation_date = db.Column(db.DateTime, default=db.func.current_timestamp())
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    updated_at = db.Column(db.DateTime, default=db.func.current_timestamp(), onupdate=db.func.current_timestamp())

    __table_args__ = (db.UniqueConstraint('phone', name='unique_phone_constraint'),)

class MenuItem(db.Model):
    __tablename__ = 'menu_item'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    category = db.Column(db.String(20))
    course = db.Column(db.String(20))
    price = db.Column(db.Float)
    image_url = db.Column(db.String(200))

class Orders(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(20), db.ForeignKey('reservations.phone'))
    items = db.Column(db.JSON)
    total = db.Column(db.Float)
    status = db.Column(db.String(20), default='pending')

class Payment(db.Model):
    __tablename__ = 'payment'
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(20), db.ForeignKey('reservations.phone'))
    amount = db.Column(db.Float)
    method = db.Column(db.String(20))
    status = db.Column(db.String(20), default='pending')

# API Endpoints
@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.json
    existing_reservation = Reservation.query.filter_by(phone=data['phone']).first()
    if existing_reservation:
        return jsonify({
            'id': existing_reservation.id,
            'message': 'Existing reservation found',
            'present': existing_reservation.present
        }), 200
    reservation = Reservation(
        name=data['name'],
        people=data['people'],
        phone=data['phone'],
        present=data.get('present', 'no')  # Allow client to set 'present' if needed
    )
    db.session.add(reservation)
    db.session.commit()
    return jsonify({
        'id': reservation.id,
        'present': reservation.present,
        'status': reservation.status
    }), 201

@app.route('/api/check-reservation', methods=['GET'])
def check_reservation():
    phone = request.args.get('phone')
    if not phone:
        return jsonify({'error': 'Phone number is required'}), 400
    
    reservation = Reservation.query.filter_by(phone=phone).first()
    if reservation:
        return jsonify({
            'id': reservation.id,
            'name': reservation.name,
            'people': reservation.people,
            'phone': reservation.phone,
            'status': reservation.status,
            'present': reservation.present,
            'reservation_date': reservation.reservation_date.isoformat(),
            'created_at': reservation.created_at.isoformat(),
            'updated_at': reservation.updated_at.isoformat()
        }), 200
    return jsonify({'present': 'no', 'message': 'No reservation found'}), 404

@app.route('/api/reservations/<phone>/status', methods=['PUT'])
def update_reservation_status(phone):
    reservation = Reservation.query.filter_by(phone=phone).first_or_404()
    data = request.json
    reservation.status = data.get('status', reservation.status)
    db.session.commit()
    return jsonify({'message': 'Status updated', 'status': reservation.status}), 200

@app.route('/api/menu', methods=['GET'])
def get_menu():
    category = request.args.get('category')
    course = request.args.get('course')
    
    query = MenuItem.query
    if category:
        query = query.filter_by(category=category)
    if course and course != 'all':
        query = query.filter_by(course=course)
    
    items = query.all()
    return jsonify([{
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'category': item.category,
        'course': item.course,
        'image_url': item.image_url
    } for item in items])

@app.route('/api/orders', methods=['POST'])
def create_order():
    data = request.json
    order = Orders(
        phone=data['phone'],
        items=data['items'],
        total=data['total'],
        status='pending'
    )
    db.session.add(order)
    db.session.commit()
    return jsonify({'order_id': order.id, 'phone': order.phone}), 201

@app.route('/api/orders/<phone>', methods=['GET'])
def get_orders(phone):
    orders = Orders.query.filter_by(phone=phone, status='pending').all()
    total_amount = sum(order.total for order in orders)
    return jsonify({
        'orders': [{
            'id': order.id,
            'phone': order.phone,
            'items': order.items,
            'total': order.total,
            'status': order.status
        } for order in orders],
        'total_amount': total_amount
    })

@app.route('/api/payments', methods=['POST'])
def process_payment():
    data = request.json
    phone = data['phone']
    orders = Orders.query.filter_by(phone=phone, status='pending').all()
    if not orders:
        return jsonify({'status': 'error', 'message': 'No pending orders found'}), 400
    
    total_amount = sum(order.total for order in orders)
    payment = Payment(
        phone=phone,
        amount=total_amount,
        method=data['method'],
        status='success'
    )
    for order in orders:
        order.status = 'completed'
    reservation = Reservation.query.filter_by(phone=phone).first()
    if reservation:
        reservation.status = 'completed'  # Update reservation status on payment success
    db.session.add(payment)
    db.session.commit()
    return jsonify({'status': payment.status, 'total_amount': total_amount})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)