from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:rizz123*@localhost:5432/restaurant_db'
db = SQLAlchemy(app)

# Models
class Reservation(db.Model):
    __tablename__ = 'reservation'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    people = db.Column(db.Integer)
    # Add a unique constraint that PostgreSQL will recognize
    phone = db.Column(db.String(20), unique=True)
    status = db.Column(db.String(20), default='pending')
    
    # Add an explicit unique constraint that PostgreSQL will use for foreign key references
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
    phone = db.Column(db.String(20), db.ForeignKey('reservation.phone'))
    items = db.Column(db.JSON)
    total = db.Column(db.Float)
    status = db.Column(db.String(20), default='pending')

class Payment(db.Model):
    __tablename__ = 'payment'
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(20), db.ForeignKey('reservation.phone'))
    amount = db.Column(db.Float)
    method = db.Column(db.String(20))
    status = db.Column(db.String(20), default='pending')


# API Endpoints
@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.json
    existing_reservation = Reservation.query.filter_by(phone=data['phone']).first()
    if existing_reservation:
        return jsonify({'id': existing_reservation.id, 'message': 'Existing reservation found'}), 200
    reservation = Reservation(
        name=data['name'],
        people=data['people'],
        phone=data['phone']
    )
    db.session.add(reservation)
    db.session.commit()
    return jsonify({'id': reservation.id}), 201

@app.route('/api/menu', methods=['GET'])
def get_menu():
    category = request.args.get('category')
    course = request.args.get('course')
    
    query = MenuItem.query.filter_by(category=category)
    if course and course != 'all':
        query = query.filter_by(course=course)
    
    items = query.all()
    return jsonify([{
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'category': item.category,
        'course': item.course,  # Include course in response
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
            'phone': order.phone,  # Add phone
            'items': order.items,
            'total': order.total,
            'status': order.status  # Add status
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
    db.session.add(payment)
    db.session.commit()
    return jsonify({'status': payment.status, 'total_amount': total_amount})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)