# ElevateAI - AI-Powered Technology Solutions for Startups

ElevateAI is a comprehensive technology solutions provider specializing in helping early-stage startups conceptualize, design, and develop scalable, AI-powered products. Our modern web application showcases our expertise in transforming innovative ideas into market-ready digital solutions.

## About ElevateAI

We operate as a tech partner, enabling startups to accelerate their product development cycle, reduce time-to-market, and enhance user engagement through innovative technology solutions. Our services include:

- **Custom Web & Mobile Applications** – Frontend and backend development tailored to client needs
- **AI Integration** – Implementing AI-driven features such as automation, data analytics, and predictive models
- **Technical Consultancy** – Providing strategic guidance for product architecture, technology stack selection, and scalability planning
- **UI/UX Design** – Crafting intuitive and engaging user interfaces
- **Ongoing Support & Maintenance** – Ensuring continuous performance optimization and feature upgrades

## Features

- **Modern, Responsive Design** - Mobile-first approach with beautiful, professional UI
- **Interactive User Experience** - Smooth animations, hover effects, and dynamic content
- **Comprehensive Service Showcase** - Detailed pages for each service offering
- **Enhanced Contact System** - Multi-field contact form with service and budget selection
- **Database Integration** - SQLite database for storing contact inquiries
- **SEO-Optimized** - Clean, semantic HTML structure
- **Performance Optimized** - Fast loading times and efficient code

## Tech Stack

- **Backend**: Python 3.8+, Flask
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Database**: SQLite with SQLAlchemy ORM
- **Styling**: Bootstrap 5, Custom CSS
- **Icons**: Font Awesome 6
- **Animations**: CSS3 animations with Intersection Observer API

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Modern web browser

## Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/elevateai.git
cd elevateai
```

2. **Create a virtual environment:**
```bash
python -m venv venv
```

3. **Activate the virtual environment:**
   - Windows:
   ```bash
   venv\Scripts\activate
   ```
   - Unix/MacOS:
   ```bash
   source venv/bin/activate
   ```

4. **Install dependencies:**
```bash
pip install -r requirements.txt
```

## Running the Application

1. **Start the Flask development server:**
```bash
python app.py
```

2. **Open your web browser and navigate to:**
```
http://localhost:5000
```

## Project Structure

```
elevateai/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── instance/             # Database files
│   └── elevateai.db     # SQLite database
├── static/              # Static assets
│   ├── css/
│   │   └── style.css    # Custom stylesheets
│   └── js/
│       └── main.js      # JavaScript functionality
├── templates/           # HTML templates
│   ├── base.html       # Base template with navigation
│   ├── index.html      # Home page
│   ├── about.html      # About page
│   ├── services.html   # Services page
│   └── contact.html    # Contact page
├── venv/               # Virtual environment
└── README.md          # Project documentation
```

## Key Features Implementation

### 1. Enhanced Contact Form
- Multi-field form with company, phone, service selection, and budget range
- Client-side validation with real-time feedback
- AJAX submission with loading states
- Database storage with SQLAlchemy

### 2. Service Showcase
- Detailed service descriptions with features and benefits
- Interactive cards with hover effects
- Process visualization with step-by-step approach
- Specialized solutions section

### 3. About Page
- Company mission and values
- Team expertise showcase
- Statistics and achievements
- Development approach explanation

### 4. Responsive Design
- Mobile-first approach
- Bootstrap 5 grid system
- Custom CSS for enhanced styling
- Smooth animations and transitions

## Database Schema

The application uses a SQLite database with the following structure:

```sql
CREATE TABLE contact (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    company VARCHAR(100),
    phone VARCHAR(20),
    service VARCHAR(50),
    budget VARCHAR(30),
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## Customization

### Adding New Services
1. Update the services section in `templates/services.html`
2. Add corresponding CSS styles in `static/css/style.css`
3. Update the contact form service options in `templates/contact.html`

### Modifying Styling
- Primary colors are defined in CSS variables at the top of `static/css/style.css`
- Bootstrap classes are used for layout and basic styling
- Custom animations are defined in the JavaScript file

### Database Modifications
- Update the Contact model in `app.py`
- Run database migrations if needed
- Update form handling in the contact route

## Deployment

### Local Development
```bash
python app.py
```

### Production Deployment
1. Set environment variables:
```bash
export FLASK_ENV=production
export SECRET_KEY=your-secret-key
```

2. Use a production WSGI server like Gunicorn:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 app:app
```

3. Set up a reverse proxy (nginx) for SSL termination and static file serving

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any inquiries about ElevateAI services, please reach out through our contact form at [elevateai.com/contact](http://elevateai.com/contact) or email us at admin@elevateai.co.in.

---

**ElevateAI** - Transforming startup ideas into scalable, AI-powered products. 