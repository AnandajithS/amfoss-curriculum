'use client';
import '../globals.css'
import Image from 'next/image';
import Link from 'next/link';

export default function Section({ title, movies }) {
  return (
    <div className="section">
      <h2>{title}</h2>
      <div className="movies">
      
        {movies?.map((movie) => (
          <Link href={`/movie/${movie.id}`} key={movie.id}>
            <div className="flex flex-col curser-pointer select-none text-[#FFFFFF]">
              <Image
                src={`https://image.tmdb.org/t/p/w500${movie.poster_path}`}
                alt="movie"
                className="poster"
                width={120}
                height={180}
              />
              <p title={movie.title} className="w-[120px] truncate text-[16px] text-center">{movie.title}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
