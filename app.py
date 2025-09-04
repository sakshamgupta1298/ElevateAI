from flask import Flask, render_template, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///elevateiq.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    company = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    service = db.Column(db.String(50))
    budget = db.Column(db.String(30))
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

def init_db():
    with app.app_context():
        try:
            db.create_all()
            print("Database initialized successfully")
        except Exception as e:
            print(f"Database initialization error: {e}")

# Initialize database
init_db()

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/services')
def services():
    return render_template('services.html')

# @app.route('/customers')
# def customers():
#     return render_template('customers.html')

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        try:
            name = request.form.get('name')
            email = request.form.get('email')
            company = request.form.get('company')
            phone = request.form.get('phone')
            service = request.form.get('service')
            budget = request.form.get('budget')
            message = request.form.get('message')
            
            new_contact = Contact(
                name=name, 
                email=email, 
                company=company,
                phone=phone,
                service=service,
                budget=budget,
                message=message
            )
            db.session.add(new_contact)
            db.session.commit()
            
            return jsonify({'success': True, 'message': 'Thank you for your message! We will get back to you within 24 hours.'})
        except Exception as e:
            db.session.rollback()
            return jsonify({'success': False, 'message': 'An error occurred. Please try again.'}), 500
    
    return render_template('contact.html')

if __name__ == '__main__':
    # For production, use environment variables
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug) 