import Header from './components/Header';
import {AuthProvider} from './components/authcontext'
import './globals.css';

export const metadata = {
  title: 'Letterboxd',
  description: 'Movie review site',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
        <Header />
        {children}
        </AuthProvider>
      </body>
    </html>
  );
}
