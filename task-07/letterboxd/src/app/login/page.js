'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation';
import { useAuth } from '../components/authcontext';
import '../globals.css';
import Image from 'next/image';

export default function Login(){
        const router = useRouter();
        const { setIsLoggedIn, setUser} = useAuth();
        const [formData, setFormData] = useState({
            usernameOrEmail:'',
            password:'',
        });
    
        const handleChange= (e)=>{
            setFormData({...formData,[e.target.name]:e.target.value});
        };
    
        const handleSubmit = async (e) => {
            e.preventDefault(); // prevent page reload
            const response = await fetch('http://localhost:5000/api/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(formData),
            });
        
            const data = await response.json();
            alert(data.message);
            if (response.ok) {
                const loggedInUser = { username: data.username, user_id: data.user_id };
                localStorage.setItem('user', JSON.stringify(loggedInUser));
                setIsLoggedIn(true);
                setUser(loggedInUser); 
                router.push('/');
              }
              
          };

    return (
        <div className="flex items-center justify-center h-screen">
            <div className='w-3/4 h-3/4 bg-[#34312D] flex'>
            <div className="w-3/4 h-full text-white rounded-md p-8">
            <h2 className="text-[50px] font-bold ml-[10%]">Login</h2>
            <form className='space-y-6' onSubmit={handleSubmit}>
                <div className='pl-[40px] pb-[25px]'>
                    <label htmlFor="username" className=" block mb-[40px] text-[30px]">Username: </label>
                    <input id="username" type="text" name="usernameOrEmail" className="w-3/4 h-[20px] p-[8px] rounded-[20px]" onChange={handleChange}></input>
                </div>    
                <div className='pl-[40px] pb-[25px]'>
                    <label htmlFor="password" className=" block mb-[40px] text-[30px]">Password: </label>
                    <input id="password" type="password" name="password" className="w-3/4 p-[8px] h-[20px] rounded-[20px]" onChange={handleChange}></input> 
                </div>
                <div className='pl-[40px] pb-[25px];'>
                <input type="submit" className="w-3/4 h-[30px] p-[10px] rounded-[20px] mb-[20px]"></input>
                </div>
            </form>           
            </div>
            <div className="w-1/4 relative"> 
            <Image src={'/images/fill.jpg'} alt='Illustration' fill className="object-cover"></Image>
            </div>
            </div>
        </div>
    );
}