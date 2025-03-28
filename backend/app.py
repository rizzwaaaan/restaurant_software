from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:rizz123*@localhost:5432/restaurant_db'
db = SQLAlchemy(app)

# Models
class Reservation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    people = db.Column(db.Integer)
    phone = db.Column(db.String(20))
    status = db.Column(db.String(20), default='pending')

class MenuItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    category = db.Column(db.String(20))
    course = db.Column(db.String(20))
    price = db.Column(db.Float)
    image_url = db.Column(db.String(200))  # Added image URL field

class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    items = db.Column(db.JSON)
    total = db.Column(db.Float)
    status = db.Column(db.String(20), default='pending')

class Payment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer)
    amount = db.Column(db.Float)
    method = db.Column(db.String(20))
    status = db.Column(db.String(20), default='pending')

# API Endpoints
@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.json
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
    items = MenuItem.query.filter_by(category=category).all()
    return jsonify([{
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'category': item.category,
        'image_url': item.image_url  # Include image URL in response
    } for item in items])

@app.route('/api/orders', methods=['POST'])
def create_order():
    data = request.json
    order = Order(
        items=data['items'],
        total=data['total'],
        status='pending'
    )
    db.session.add(order)
    db.session.commit()
    return jsonify({'order_id': order.id}), 201

@app.route('/api/payments', methods=['POST'])
def process_payment():
    data = request.json
    payment = Payment(
        order_id=data['order_id'],
        amount=data['amount'],
        method=data['method'],
        status='success'  # Simulated success
    )
    db.session.add(payment)
    db.session.commit()
    return jsonify({'status': payment.status})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)