'use client';

import { useState } from 'react';
import Section from '../components/Section';

export default function SearchPage() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [searched, setSearched] = useState(false);

  const handleSearch = async () => {
    if (!query.trim()) return;

    try {
      const res = await fetch(`http://localhost:5000/api/search?term=${encodeURIComponent(query)}`);
      const data = await res.json();
      setResults(data['Search Results'] || []);
      setSearched(true);
    } catch (err) {
      console.error('Error fetching search:', err);
      setResults([]);
      setSearched(true);
    }
  };

  const clearQuery = () => {
    setQuery('');
    setResults([]);
    setSearched(false);
  };

  return (
    <div className="min-h-screen bg-[#1A1A1A] text-[#FFFFFF] px-[24px] py-[32px]">
      <h1 className="text-[36px] font-bold text-center mb-[24px]">SEARCH</h1>

      {/* Search Input + Button */}
      <div className="flex justify-center gap-[16px] mb-[24px] max-w-[768px] mx-auto">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search for a movie..."
          className="w-full px-[16px] py-[12px] rounded-full text-[#000000] text-[15px] outline-none"
        />
        <button
          onClick={handleSearch}
          className="bg-[#FFB84D] text-[#000000] font-bold px-[24px] py-[12px] rounded-full"
        >
          Search
        </button>
        {query && (
          <button onClick={clearQuery} className="text-[10px] text-[#BDBDBD]">
            Clear
          </button>
        )}
      </div>

      {/* Results */}
      <div className="max-w-6xl mx-auto">
        {results.length > 0 ? (
          <Section title="Search Results" movies={results} />
        ) : searched ? (
          <p className="text-center text-[#BDBDBD]">No movies found.</p>
        ) : null}
      </div>
    </div>
  );
}
