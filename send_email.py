import sys
import win32com.client as win32


def gen_email_message(msg_body, subject, recipient, bcc=None):
    """
    Generate and send Email message

    Args:
        msg_body (str): Message body of email to send
        subject (str): Email subject
        recipient (str): Email recipient
        bcc (str): BCC list
    """
    outlook = win32.Dispatch('outlook.application')
    mail = outlook.CreateItem(0)
    mail.To = recipient
    mail.Subject = subject
    mail.HtmlBody = msg_body
    if bcc is not None:
        mail.BCC = bcc
    mail.send  # This is on purpose, no () needed
    
#text = "Hello,\nHere is a test email!"
#gen_email_message(text, "TEST EMAIL", "jeremymgreenwood@gmail.com", "")

msg_body = sys.argv[1]
subject = sys.argv[2]
recipient = sys.argv[3]

print("body:")
print(repr(msg_body))
print("sub:")
print(subject)
print("email:")
print(recipient)

#gen_email_message("Hello,\nHere is a test email 1", subject, recipient)
#gen_email_message("Hello,\r\nHere is a test email 2", subject, recipient)
#gen_email_message("Hello,<br>Here is a test email 3", subject, recipient)
#quit()

gen_email_message(msg_body, subject, recipient)