'use client';
import React, { useState } from 'react'
import { Rating } from 'react-simple-star-rating'

export default function StarRating({
  readonly = false,
  initialRating = 0,
  onRatingChange = () => {}
}) {
  const [rating, setRating] = useState(initialRating)

  const handleRating = (rate) => {
    setRating(rate)
    onRatingChange(rate)  // Notify parent
  }

  return (
    <div className='App'>
      <Rating
        onClick={handleRating}
        readonly={readonly}
        initialValue={rating}
        allowFraction
      />
    </div>
  )
}
