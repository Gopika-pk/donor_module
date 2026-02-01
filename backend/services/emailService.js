const nodemailer = require("nodemailer");
require("dotenv").config();

// ------------------------
// Nodemailer Transporter (Brevo SMTP)
// ------------------------
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,               // smtp-relay.brevo.com
  port: Number(process.env.EMAIL_PORT),       // 587
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,             // Brevo login
    pass: process.env.EMAIL_PASS,             // Brevo SMTP key
  },
});

// Verify SMTP connection on server start
transporter.verify((error) => {
  if (error) {
    console.error("❌ SMTP connection failed:", error);
  } else {
    console.log("✅ Brevo SMTP connected successfully");
  }
});

/**
 * Send camp manager credentials via email
 * @param {string} recipientEmail - Camp manager's email
 * @param {string} campName - Name of the camp
 * @param {string} campId - Generated camp ID
 * @param {string} managerName - Camp manager's name
 * @param {string} password - Generated password
 * @param {string} location - Camp location
 */
async function sendCampCredentials({
  recipientEmail,
  campName,
  campId,
  managerName,
  password,
  location,
}) {
  try {
    await transporter.sendMail({
      from: `"Sahaya Support" <disasterrelief.sahaya@gmail.com>`,
      to: recipientEmail,
      subject: `Camp Manager Credentials - ${campName}`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #1E88E5; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
            .content { background-color: #f9f9f9; padding: 30px; border: 1px solid #ddd; border-radius: 0 0 5px 5px; }
            .credentials { background-color: white; padding: 20px; margin: 20px 0; border-left: 4px solid #1E88E5; }
            .credential-item { margin: 10px 0; }
            .credential-label { font-weight: bold; color: #555; }
            .credential-value { color: #1E88E5; font-size: 16px; }
            .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #777; text-align: center; }
            .warning { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Welcome to Sahaya Disaster Relief</h1>
            </div>
            <div class="content">
              <p>Dear ${managerName},</p>
              
              <p>You have been registered as a Camp Manager for <strong>${campName}</strong>. Below are your login credentials to access the Camp Manager portal.</p>
              
              <div class="credentials">
                <h3>Your Camp Details</h3>
                <div class="credential-item">
                  <span class="credential-label">Camp ID:</span>
                  <span class="credential-value">${campId}</span>
                </div>
                <div class="credential-item">
                  <span class="credential-label">Camp Name:</span>
                  <span class="credential-value">${campName}</span>
                </div>
                <div class="credential-item">
                  <span class="credential-label">Location:</span>
                  <span class="credential-value">${location}</span>
                </div>
              </div>

              <div class="credentials">
                <h3>Login Credentials</h3>
                <div class="credential-item">
                  <span class="credential-label">Email:</span>
                  <span class="credential-value">${recipientEmail}</span>
                </div>
                <div class="credential-item">
                  <span class="credential-label">Password:</span>
                  <span class="credential-value">${password}</span>
                </div>
              </div>

              <div class="warning">
                <strong>⚠️ Security Notice:</strong> Please change your password after your first login. Keep your credentials secure and do not share them with unauthorized persons.
              </div>

              <p><strong>How to Login:</strong></p>
              <ol>
                <li>Open the Sahaya Disaster Relief app</li>
                <li>Select "Login as Camp Manager"</li>
                <li>Enter your email and password</li>
                <li>Start managing your camp's inventory requests</li>
              </ol>

              <p>If you have any questions or need assistance, please contact the admin team.</p>

              <p>Best regards,<br>
              <strong>Sahaya Disaster Relief Team</strong></p>
            </div>
            <div class="footer">
              <p>This is an automated email. Please do not reply to this message.</p>
              <p>&copy; 2026 Sahaya Disaster Relief. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `,
    });

    console.log("✅ Credentials email sent successfully to:", recipientEmail);
    return { success: true };
  } catch (error) {
    console.error("❌ Failed to send credentials email:", error);
    throw error;
  }
}

module.exports = { sendCampCredentials };
