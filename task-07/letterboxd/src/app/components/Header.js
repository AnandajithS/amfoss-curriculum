'use client';
import { useRouter } from 'next/navigation';
import { useAuth } from './authcontext';
import '../globals.css';

export default function Header() {
  const router = useRouter();
  const { isLoggedIn, setIsLoggedIn, user} = useAuth();

  const handleLogout = () => {
    localStorage.removeItem('user');
    setIsLoggedIn(false);
    router.push('/login');
  };

  return (
    <div className="header">
      <div onClick={() => router.push('/')} className="logo cursor-pointer select-none">
        LETTERBOXD
      </div>
      <div className="actions">
        <button onClick={() => router.push('/search')}>Search</button>
        {!isLoggedIn ? (
          <>
            <button onClick={() => router.push('/register')}>Register</button>
            <button onClick={() => router.push('/login')}>Login</button>
          </>
        ) : (
          <>
            <button onClick={handleLogout}>Logout</button>
            <span className="icon cursor-pointer select-none" onClick={() => router.push(`/Profile/${user.user_id}`)}>👤</span>
          </>
        )}
      </div>
    </div>
  );
}
