from app import app, db
from reviews import Review

with app.app_context():  # Use app context for DB access
    reviews = Review.query.all()
    print(reviews)

