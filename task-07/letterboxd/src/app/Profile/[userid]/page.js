'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import { Rating } from 'react-simple-star-rating';
import Section from '../../components/Section';
import { useAuth } from '../../components/authcontext';


export default function Profile() {
  const { user } = useAuth();
  const userId = user?.user_id;
  const [userData, setUserData] = useState(null);
  const [Credentials, setCredentials] = useState({
    currentPassword: '',
    newPassword: '',
    reenterPassword: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setCredentials((prevData) => ({
      ...prevData,
      [name]: value
    }))
    console.log("Changing",name,value);
  };

  const handleResetPassword = async (e) => {
    e.preventDefault(); // This prevents the form from reloading the page
  
    const { currentPassword, newPassword, reenterPassword } = Credentials;
  
    if (newPassword !== reenterPassword) {
      alert("Passwords do not match.");
      return;
    }
  
    try {
      const res = await fetch('http://localhost:5000/api/reset_password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: userId,
          currentPassword: currentPassword,
          newPassword: newPassword
        })
      });
  
      let data;
      try {
        data = await res.json();
      } catch (jsonErr) {
        console.error("Failed to parse JSON:", jsonErr);
      }
  
      console.log("Status:", res.status);
      console.log("Response JSON:", data);
  
      if (res.ok) {
        alert(data.message || "Password reset successful.");
        setCredentials({
          currentPassword: '',
          newPassword: '',
          reenterPassword: ''
        });
      } else {
        alert((data && data.message) || 'Something went wrong.');
      }
    } catch (err) {
      console.error("Network error:", err);
      alert('An error occurred.');
    }
  };
  
  

  useEffect(() => {
    // Fetch user profile data from the backend
    const fetchUserData = async () => {
      const res = await fetch(`http://localhost:5000/api/profile/${userId}`);
      const data = await res.json();
      if (res.ok) {
        setUserData(data);
      } else {
        console.error(data.message || 'Failed to fetch profile data');
      }
    };

    fetchUserData();
  }, [userId]);

  if (!userData) {
    return <div>Loading...</div>;
  }


  return (
    <div className='p-[25px]'>
      <div className="text-center">
        <div>
          <Image
            src={'/images/profilepic.jpeg'} // Default image in case profilePic is not available
            alt="Profile pic"
            width={128}
            height={128}
            className="rounded-full mx-auto mt-[20px]"
          />
        </div>
        <h1 className="text-xl font-semibold">{userData.username}</h1>
      </div>

      <div className="mt-[24px]">
        <h2 className="text-[25px] font-[600] mb-[8px]">Account details</h2>
        <div className="flex items-center justify-center">
          <div className='w-3/4 p-[15px] text-[20px] rounded-[10px] bg-[#34312D] flex flex-col space-y-[8px]'>
            <p>Email id: {userData.email}</p>
          </div>
        </div>
      </div>

      <div className="mt-[24px]">
        <h2 className="font-[600] mb-[8px]">Reset password</h2>
        <div className="flex justify-center">
          <div className="w-3/4 space-y-[12px] bg-[#34312D] p-[15px] rounded-[6px]">
            <form className="space-y-[12px]">
              <div className="flex items-center space-x-[10px] mb-[40px]">
                <label htmlFor="current" className="w-[300px] text-[20px]">Enter current password:</label>
                <input
                  type="password"
                  id="current"
                  name="currentPassword"
                  value={Credentials.currentPassword}
                  onChange={handleChange}
                  className="w-[750px] h-[20px] rounded "
                />
              </div>

              <div className="flex items-center space-x-[10px] mb-[40px]">
                <label htmlFor="new" className="w-[300px] text-[20px]">Enter new password:</label>
                <input
                  type="password"
                  id="new"
                  name="newPassword"
                  value={Credentials.newPassword}
                  onChange={handleChange}
                  className="w-[750px] h-[20px] rounded"
                />
              </div>

              <div className="flex items-center space-x-[10px] mb-[40px]">
                <label htmlFor="reenter" className="w-[300px] text-[20px]">Re-enter new password:</label>
                <input
                  type="password"
                  id="reenter"
                  name="reenterPassword"
                  value={Credentials.reenterPassword}
                  onChange={handleChange}
                  className="w-[750px] h-[20px] rounded "
                />
              </div>
              <div className="flex justify-center space-x-[10px]">
                <input
                  type="submit"
                  id="submit"
                  name="submit"
                  className="w-[100%] h-[32px] rounded "
                  onClick={handleResetPassword}
                />
              </div>
            </form>
          </div>
        </div>
      </div>

      <Section title="Watchlist" movies={userData.watchlist} />

      <div className="mt-[24px]">
        <h2 className="text-[18px] font-[600] mb-[16px]">My reviews</h2>
        <div className="flex flex-col gap-[16px]">
          {userData.reviews.map((review, i) => (
            <div key={i} className="flex bg-[#2A2A2A] rounded-[8px] p-[16px] gap-[16px]">
              <Image 
                src={`https://image.tmdb.org/t/p/w500${review.poster_path}`} 
                alt="review"
                width={80} 
                height={110} 
                className="rounded-[8px] flex-shrink-0"
              />
              <div className="flex flex-col justify-between">
                <p className="text-[14px] text-justify">{review.comment}</p>
                <div className="flex items-center gap-[8px] mt-[12px]">
                  <p className="text-[14px]">Your rating:</p>
                  <Rating readonly initialValue={review.rating} size={20} />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
