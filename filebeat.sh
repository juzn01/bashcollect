#!/bin/bash
echo "-----BEGIN CERTIFICATE-----
MIIDbjCCAlagAwIBAgIJALmanoYHsXisMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMTkwOTA1MDI1MTQwWhcNMjkwOTAyMDI1MTQwWjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAyQu1UGAWbe7sa5jvgKltCaSccHQrFJKIbS4ncDU9dGWP//lFe3+ryJ35
UEnocRBYB7VBDxp3mM6G543g4Mc/AhWmwKpMsTwihyFuocNqe6EUkfXzhtO0UGIZ
MysC72PWvvrguC06HsNvWBC7H7yAVbKLxzOPRkeGBHO1ycpcEj9uhp00i6DP7mbv
yPMemfs63ttNgp1WfXB9KfaeeFqzuRelV0XXmljBTE08+EGcs51XBKQXuJ1CtpoG
2hlfht2KvTvFmSks1qbErf+Ib+pFc4D/ENbxd6lbmSTSBT+uw8jgiduIHF520Oc2
SE8Z5FfMOV+HXCYllHseAv9TXx8gRQIDAQABo2EwXzAPBgNVHREECDAGhwQKCf8o
MB0GA1UdDgQWBBRl7y/i5vcdjlUxBpBud0h29D5J6jAfBgNVHSMEGDAWgBRl7y/i
5vcdjlUxBpBud0h29D5J6jAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IB
AQAPEryJE6ZWxnEJsXnIpmXOCHbCE21QD1Hsp1tDn5zc5VdCpUuLsSH/kL8C9mA5
BIXSVsxsTGfsPRLdVKQdV4utH2e1UkXp1sIy00FnZVnmVhYZGQtNtG2MPLGJj69Y
wX9CvduSU7VzW7bfpRT8NmgHzk9HCgLwK7maBVmnpRZYidJwsgYm2EG7yPyRnqpT
yLgxwxANpeUBfgS4Nlxn/gv7ZgKu4auWh64mM4gD+cygwaN5tZ8DeQTX/+G6hEwC
3a4Z50RGlYDUl7egj1ePljQIxef927oBDEB1NvvHy9jsikSomenHRSwnUWRsDARJ
HXlNUbe5K0W+awoytTJN3H5M
-----END CERTIFICATE-----" > /tmp/logstash-forwarder.crt
sudo mkdir -p /etc/pki/tls/certs
sudo cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/
echo "deb https://packages.elastic.co/beats/apt stable main" |  sudo tee -a /etc/apt/sources.list.d/beats.list
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get update
sudo apt-get install filebeat
sudo echo "filebeat:
  prospectors:
    -
      paths:
        - /var/log/auth.log
        - /var/log/syslog
      #  - /var/log/*.log

      input_type: log
      
      document_type: syslog

  registry_file: /var/lib/filebeat/registry

output:
  logstash:
    hosts: [\"10.9.255.40:5044\"]
    bulk_max_size: 1024

    tls:
      certificate_authorities: [\"/etc/pki/tls/certs/logstash-forwarder.crt\"]

shipper:

logging:
  files:
    rotateeverybytes: 10485760 # = 10MB " > /etc/filebeat/filebeat.yml
sudo service filebeat restart
sudo update-rc.d filebeat defaults 95 10


