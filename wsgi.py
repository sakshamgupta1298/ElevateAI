#!/usr/bin/env python3
"""
WSGI entry point for ElevateAI Flask application
"""
import os
import sys

# Add the project directory to the Python path
project_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, project_dir)

from app import app as application

if __name__ == "__main__":
    application.run()
