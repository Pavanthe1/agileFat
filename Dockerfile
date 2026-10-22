FROM nginx:latest

# Copy the frontend portal code to Nginx default public directory
COPY index.html /usr/share/nginx/html/index.html

# Add tracking text file as requested by template guidelines
RUN echo "E-Waste Collection Portal Application" > /usr/share/nginx/html/project.txt

EXPOSE 80
