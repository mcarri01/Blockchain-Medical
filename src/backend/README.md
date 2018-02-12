# Back-end

## Setup:

### Install virtualenv:
'''
sudo apt-get install virtualenv
'''
### Create a virtual environment:
'''
~$ virtualenv ~/env
''' 

### Activate the environment:
'''
source ~/env/bin/activate
'''
To deactivate, simply run:
'''
deactivate
'''

### Install flask:
'''
sudo pip install flask==0.10.1
'''
### Verify installation:
'''
pip freeze
'''
You should see Flask and its dependencies installed.

## Running the application:
'''
python app.py
'''

The application should start running on localhost.



