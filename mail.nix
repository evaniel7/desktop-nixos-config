{ config, pkgs, ... }:

let
  email = "evanh77777@gmail.com";
  secret = "/etc/nixos-secrets/smtp-password";
  passCmd = "tr -d '\\n' < ${secret}";
in
{
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      port = 587;
      tls = true;
      tls_starttls = true;
      auth = true;
      logfile = "~/.msmtp.log";
    };
    accounts.default = {
      host = "smtp.gmail.com";
      from = email;
      user = email;
      passwordeval = passCmd;
    };
  };

  environment.systemPackages = with pkgs; [
    mailutils
    isync        # provides mbsync
    neomutt
    msmtp
  ];

  environment.etc."mbsyncrc".text = ''
    IMAPAccount gmail
    Host imap.gmail.com
    Port 993
    User ${email}
    PassCmd "${passCmd}"
    TLSType IMAPS
    CertificateFile /etc/ssl/certs/ca-certificates.crt

    IMAPStore gmail-remote
    Account gmail

    MaildirStore gmail-local
    Subfolders Verbatim
    Path ~/Mail/gmail/
    Inbox ~/Mail/gmail/Inbox

    Channel gmail-inbox
    Far :gmail-remote:INBOX
    Near :gmail-local:Inbox
    Create Near
    SyncState *

    Channel gmail-sent
    Far :gmail-remote:"[Gmail]/Sent Mail"
    Near :gmail-local:Sent
    Create Near
    SyncState *

    Group gmail
    Channel gmail-inbox
    Channel gmail-sent
  '';
}
