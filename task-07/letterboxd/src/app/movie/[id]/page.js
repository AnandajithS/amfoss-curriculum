'use client';

import { useParams } from 'next/navigation';
import { useEffect, useState } from 'react';
import Image from 'next/image';
import StarRating from '../../components/StarRating';
import { useAuth } from '../../components/authcontext';


export default function MovieReview() {
  const { user } = useAuth();
  const userId = user?.user_id;
  const {id} = useParams()
  console.log("Movie ID:",id)
  const [movieData, setMovieData] = useState(null);
  const [reviews, setReviews] = useState(null);
  const [reviewText, setReviewText] = useState(''); 
  const [inWatchlist, setInWatchlist] = useState(false);
  const [userRating, setUserRating] = useState(0);



  const handleAddToWatchlist = async () => {
    if (inWatchlist) {
      // If the movie is already in the watchlist, remove it
      try {
        const res = await fetch('http://localhost:5000/api/watchlist', {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ user_id: userId, movie_id: id }),
        });
    
        const data = await res.json();
        console.log(data.message);
        alert(data.message);  // Optional: show success or failure alert
    
        // After removal, update the state to reflect the changes
        setInWatchlist(false);
      } catch (err) {
        console.error("Failed to remove from watchlist:", err);
      }
    } else {
      // If the movie is not in the watchlist, add it
      try {
        const res = await fetch('http://localhost:5000/api/watchlist', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ user_id: userId, movie_id: id }),
        });
    
        const data = await res.json();
        console.log(data.message);
        alert(data.message);  // Optional: show success or failure alert
    
        // After adding, update the state to reflect the changes
        setInWatchlist(true);
      } catch (err) {
        console.error("Failed to add to watchlist:", err);
      }
    }
  };
  
  
  

  useEffect(() => {
    const fetchMovieData = async () => {
      const result = await fetch(`http://localhost:5000/api/movie/${id}`);
      const data = await result.json();
      setMovieData(data);
    };

    const fetchReviews = async () => {
      const result = await fetch(`http://localhost:5000/api/reviews/${id}`);
      const data = await result.json();
      setReviews(data);
    };

    const checkWatchlist = async () => {
      try {
        const res = await fetch(`http://localhost:5000/api/watchlist/${userId}`);
        const data = await res.json();
        const movieInWatchlist = data.watchlist_items.some((item) => item.movie_id == id);

        setInWatchlist(movieInWatchlist);
      } catch (err) {
        console.error("Error checking watchlist:", err);
      }
    };
    
    if (userId) checkWatchlist();
    fetchMovieData();
    fetchReviews();
  }, [id, userId]);

  // **Handle review change**
  const handleReviewChange = (e) => {
    setReviewText(e.target.value);
  };

  // **Submit review logic**
  const handleSubmitReview = async () => {
    if (reviewText.trim() === '') {
      alert('Please write a review before submitting.');
      return;
    }

    if (!user) {
      alert('User not logged in.');
      return;
    }
  
    if (!userId) {
      alert('User ID not found.');
      return;
    }

    

    try {
      const response = await fetch('http://localhost:5000/api/review', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: userId,
          movie_id: id,
          comment: reviewText,
          rating: userRating
        }),
      });

    const data = await response.json();
    console.log(reviews.averageRating)
    alert(data.message);
    setReviewText('');
    const result = await fetch(`http://localhost:5000/api/reviews/${id}`);
    const newReviews = await result.json();
    setReviews(newReviews);
    

  } catch (error) {
    console.error('Error submitting review:', error);
    alert('Failed to submit review.');
  }
};


  if (!movieData) return <p className="text-white">Loading...</p>;

  return (
    <div className="bg-[#1E1E1E] text-white p-[24px] md:p-[48px] rounded-[6px] space-y-[32px]">

      <div className="flex flex-row space-x-[32px]">
        <Image
          src={movieData.poster_path || '/public/images/profilepic.jpeg'}
          alt={movieData.title}
          width={240}
          height={360}
          className="rounded-[6px]"
        />
        <div className="mt-[16px] md:mt-0">
          <h1 className="text-[30px] font-[600]">{movieData.title} ({movieData.release_date})</h1>
          <p className="mt-[16px] text-[20px] text-[#D1D5DB]">{movieData.overview}</p>
          <button className="px-[24px] py-[12px] text-[20px] bg-[#FFD700] text-black rounded-[6px]" 
          onClick={handleAddToWatchlist}> {inWatchlist ? 'Remove from watchlist' : 'Add to watchlist'}
          </button>

        </div>
      </div>

      {/* — Cast — */}
      <div>
        <h2 className="text-[20px] font-[600] mb-[16px]">Cast</h2>
        <div className="flex flex-wrap gap-[24px]">
          {movieData.cast.map((actor, i) => (
            <div key={i} className="w-24 text-center">
              <Image
                src={actor.profile_path || '/public/images/profilepic.jpeg'}
                alt={actor.name}
                width={128}
                height={128}
                className="rounded-full mx-auto"
              />
              <p className="mt-[8px] font-[500]">{actor.name}</p>
              <p className="text-[16px] text-[#D1D5DB]">{actor.character}</p>
            </div>
          ))}
        </div>
      </div>

      {/* — Average Rating — */}
      {reviews && (
        <div className="flex items-center space-x-[8px]">
          <p className="font-[600]">Average rating:</p>
          <StarRating readonly initialValue={reviews.averageRating} allowFraction size={30} />
          <p>{reviews.averageRating}</p>
        </div>
      )}

      <div className="flex items-center space-x-[8px]">
        <p className="font-[600]">Rate this movie</p>
        <StarRating size={30} onRatingChange={(rate) => setUserRating(rate)}/>
      </div>

      {/* — Reviews — */}
      {reviews && (
        <div className="space-y-[16px]">
          <h2 className="text-[20px] font-[600]">Reviews</h2>
          {reviews.comments.map((c, i) => (
            <div key={i} className="bg-[#2A2A2A] p-[16px] rounded-[6px]">
              <p className="font-[500]">{c.user}:</p>
              <p className="mt-[4px] text-[15px]">{c.comment}</p>
            </div>
          ))}
        </div>
      )}

      {/* — Add Your Review Textarea — **Added section for adding review** */}
      <div className="space-y-[16px]">
        <h2 className="text-[20px] font-[600]">Add Your Review</h2>

        <textarea
          value={reviewText}
          onChange={handleReviewChange} // **Capture review text**
          placeholder="Write your review here..."
          className="w-full p-[12px] rounded-[6px] bg-[#2A2A2A] text-[#FFFFFF] resize-none"
          rows="5"
        />

        <button
          onClick={handleSubmitReview} // **Submit review logic**
          className="px-[24px] py-[12px] text-[20px] mt-[16px] bg-[#FFD700] text-black rounded-[6px]"
        >
          Submit Review
        </button>
      </div>

    </div>
  );
}
