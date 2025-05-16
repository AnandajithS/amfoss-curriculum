'use client'
import { useEffect, useState } from 'react';
import './globals.css'
import Section from './components/Section'


export default function HomePage() {
  const [HomeData, setHomeData]=useState(null);
  useEffect(()=>{
    const fetchHomeData=async()=>{
      const result = await fetch('http://localhost:5000/api/home');
      const data = await result.json();
      setHomeData(data);
    };

    fetchHomeData();
  },[]);

  if (!HomeData) return <p>Loading...</p>

  return (
    <div className="container">
      <Section title="New and Trending" movies={HomeData["New and Trending"]} />
      <Section title="Top Picks" movies={HomeData["Top Picks"]} />
      <Section title="Recommendations" movies={HomeData["Recommendations"]} />
    </div>
  );

}