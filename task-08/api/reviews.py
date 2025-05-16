from flask_sqlalchemy import SQLAlchemy
from flask import Blueprint, request, jsonify
from datetime import datetime
from sqlalchemy.sql import func
from auth import User
from extensions import db

class Review(db.Model):
    __tablename__ = 'reviews'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    movie_id = db.Column(db.Integer, nullable=False)
    rating = db.Column(db.Float, nullable=True)
    comment = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship(User, backref='reviews')  # Correct relationship

reviews = Blueprint('reviews', __name__)

@reviews.route('/api/review', methods=['POST'])
def submit_review():
    data = request.json
    user_id = data.get('user_id')
    movie_id = data.get('movie_id')
    rating = data.get('rating')
    comment = data.get('comment')

    # Check if the user has already reviewed this movie
    existing_review = Review.query.filter_by(user_id=user_id, movie_id=movie_id).first()

    if existing_review:
        # Update the existing review
        existing_review.rating = rating
        existing_review.comment = comment
        existing_review.created_at = datetime.utcnow()  # Fix here
        db.session.commit()

        return jsonify({'message': 'Review updated successfully'}), 200
    else:
        # Create a new review
        new_review = Review(
            user_id=user_id,
            movie_id=movie_id,
            rating=rating,
            comment=comment
        )
        db.session.add(new_review)
        db.session.commit()

        return jsonify({'message': 'Review submitted successfully'}), 201
    
@reviews.route('/api/reviews/<int:movie_id>', methods=['GET'])
def get_reviews(movie_id):
    reviews_data = (
        Review.query
        .filter_by(movie_id=movie_id)
        .join(User, Review.user_id == User.id)
        .with_entities(User.username, Review.comment, Review.rating)
        .all()
    )

    avg_rating = (
        db.session.query(func.avg(Review.rating))
        .filter_by(movie_id=movie_id)
        .scalar()
    )

    review_list = [
        {"user": r.username, "comment": r.comment, "rating": r.rating}
        for r in reviews_data
    ]

    return jsonify({
        "averageRating": round(avg_rating or 0, 1),
        "comments": review_list
    })