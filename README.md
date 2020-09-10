## Running the container  
docker run -p 5000:22 -p 8888:8888 -p 60000-60010:60000-60010/tcp -p 60000-60010:60000-60010/udp -i -t kurento-vs

## Setup Visual Studio  
Tools->Options->Cross Platform->Connection Manager  
Add->   
Host name: localhost  
Port: 5000  
User name: kurento  
Password: 1234  


