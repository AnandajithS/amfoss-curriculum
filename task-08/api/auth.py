from flask import Blueprint, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from extensions import db

auth = Blueprint('auth', __name__)

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

@auth.route('/api/register', methods=['POST'])
def register():
    data = request.json
    email = data.get('email')
    username = data.get('username')
    password = data.get('password')
    confirm_password = data.get('confirmPassword')

    if not all([email, username, password, confirm_password]):
        return jsonify({'message': 'All fields are required'}), 400

    if password != confirm_password:
        return jsonify({'message': 'Passwords do not match'}), 400

    if User.query.filter((User.username == username) | (User.email == email)).first():
        return jsonify({'message': 'Username or email already taken'}), 400

    new_user = User(email=email, username=username)
    new_user.set_password(password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'Registration successful'}), 201

@auth.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username_or_email = data.get('usernameOrEmail')
    password = data.get('password')

    if not username_or_email or not password:
        return jsonify({'message': 'Username/email and password are required'}), 400
        

    user = User.query.filter(
        (User.username == username_or_email) | (User.email == username_or_email)
    ).first()

    if user and user.check_password(password):
        return jsonify({'message': 'Login successful', 'username': user.username,'user_id':user.id}), 200
    else:
        return jsonify({'message': "Login unsuccessful"}),400

@auth.route('/api/reset_password',methods=['POST'])
def reset_password():
    data= request.json
    user_id=data.get("userId")
    current_password=data.get("currentPassword")
    new_password=data.get("newPassword")

    if not user_id or not current_password or not new_password:
        return jsonify({"message": "All fields are required."}), 400
    
    user = User.query.get(user_id)
    if not user:
        return jsonify({"message": "User not found"}), 404

    if not user.check_password(current_password):
        return jsonify({"message": "Current password is incorrect."}), 400
    
    user.set_password(new_password)
    db.session.commit()
    return jsonify({"message": "Password reset successfully."}), 200


    





