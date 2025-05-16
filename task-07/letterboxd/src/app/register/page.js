'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation';
import '../globals.css';
import Image from 'next/image';

export default function Register(){

    const router = useRouter();
    const [formData, setFormData] = useState({
        email:'',
        username:'',
        password:'',
        confirmPassword:''
    });

    const handleChange= (e)=>{
        setFormData({...formData,[e.target.name]:e.target.value});
    };

    const handleSubmit = async (e) => {
        e.preventDefault(); // prevent page reload
        const response = await fetch('http://localhost:5000/api/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData),
        });
    
        const data = await response.json();
        alert(data.message); 
        router.push('/')// feedback to user
      };

    return (
        <div className="flex items-center justify-center h-screen">
            <div className='w-3/4 h-3/4 bg-[#34312D] flex'>
            <div className="w-3/4 h-full text-white rounded-[20px]-md p-8">
            <h2 className="text-[50px] font-bold ml-[10%]">Sign up</h2>
            <form className='space-y-6' onSubmit={handleSubmit}>
                <div className='pl-[40px] pb-[25px];'>
                    <label htmlFor="email" className=" block mb-[25px] text-[25px]">Email: </label>
                    <input id="email" type="email" name="email" value={formData.email} onChange={handleChange} className="w-3/4 h-[15px] p-[10px] rounded-[20px] mb-[20px]"></input>
                </div>
                <div className='pl-[40px] pb-[25px];'>
                    <label htmlFor="username" className=" block mb-[25px] text-[25px]">Username: </label>
                    <input id="username" type="text" name="username" value={formData.username} onChange={handleChange} className="w-3/4 h-[15px] p-[10px] rounded-[20px] mb-[20px]"></input>
                </div>    
                <div className='pl-[40px] pb-[25px];'>
                    <label htmlFor="password" className=" block mb-[25px] text-[25px]">Password: </label>
                    <input id="password" type="password" name="password" value={formData.password} onChange={handleChange} className="w-3/4 p-[10px] h-[15px] rounded-[20px] mb-[20px]"></input> 
                </div>
                <div className='pl-[40px] pb-[25px];'>
                    <label htmlFor="confirm" className=" block mb-[25px] text-[25px]"> Confirm password: </label>
                    <input id="confirm" type="password" name="confirmPassword" value={formData.confirmPassword} onChange={handleChange} className="w-3/4 p-[10px] h-[15px] rounded-[20px] mb-[20px]"></input> 
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