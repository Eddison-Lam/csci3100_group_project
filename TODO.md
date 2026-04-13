# TODO

## Admin Dashboard
- Build a complete Admin Dashboard (using Rails Admin gem or custom views)
  - Subfeatures (plesase list out them)
  - Admin login permissions and role-based access control   (done)

## Additional Features

- **Stripe (Mock Payment)**     (done)
  - Reference from project spec: Some rooms or equipment may be charged  
  - Implement payment flow using Stripe in mock mode  
  - Handle charging logic during booking with success/failure processing

- **ActionCable (WebSockets)**  
  - Implement real-time notifications  
  - Includes booking status updates, cancellation alerts, waitlist changes, etc.

- **SendGrid (Email)**  (done)
  - Send email notifications via SendGrid  
  - Examples: booking confirmation emails, receipts, cancellation notices, waitlist alerts, etc.

- **Waitlist**  
  - Build waitlist mechanism  
  - Automatically notify the next student and open the slot when the previous student cancels their booking

- **Room Filter**  
  - Implement room size filtering feature  
  - Allow frontend users to filter and view rooms of different sizes

- **Daily Report**  
  - Provide daily booking summary reports for admins  
  - Includes: number of bookings, revenue (if charged), cancellations, utilization rate, etc.
