#!/bin/bash

function echo_success() {
  echo -e "\n\e[0;97m ✅ \e[1;32m$1\n\e[0m"
}

function echo_warning() {
  echo -e "\e[0;33m ⚠️  $1 \e[0m"
}

function echo_fail() {
  echo -e "\n\e[0;31m 🛑 \e[1;31m$1\n\e[0m"
}

# For debug purposes you can skip starting tailscale
if [[ "${TS_UP}" =~ [Tt][Rr][Uu][Ee] ]]; then
  if [[ "${TSD_QUIET}" =~ [Tt][Rr][Uu][Ee] ]]; then
    # Start the daemon
    tailscaled --tun=userspace-networking ${TSD_EXTRA_ARGS} &> /var/log/tailscaled &
  else
    tailscaled --tun=userspace-networking ${TSD_EXTRA_ARGS} &
  fi

  if [ $? -eq 0 ]; then
    echo_success "Tailscale daemon started successfully"
  else
    echo_fail "Failed staring the tailscale daemon"
    exit 1;
  fi

  # Connect to tailscale network
  tailscale up --authkey=${TS_AUTHKEY} --hostname=${TS_HOSTNAME} --accept-routes=${TS_ACCEPT_ROUTES} --accept-dns=${TS_ACCEPT_DNS} ${TS_EXTRA_ARGS}
  if [ $? -eq 0 ]; then
    export CURRENT_HOST=$(tailscale status --peers=false --json | jq -r '.CertDomains[0]')
    echo_success "Tailscale connected with hostname: ${CURRENT_HOST}"
  else
    echo_fail "Failed connecting to tailscale"
    exit 1;
  fi

  if [[ "${TS_CERT}" =~ [Tt][Rr][Uu][Ee] ]]; then
    echo_warning "Trying to fetch SSL certs for ${CURRENT_HOST}"
    tailscale cert --cert-file=/etc/ssl/private/tailscale.crt --key-file=/etc/ssl/private/tailscale.key ${CURRENT_HOST}
    if [ $? -eq 0 ]; then
      echo -e "\nCERT FILE:"
      openssl x509 -in /etc/ssl/private/tailscale.crt -text -noout
      echo_success "Tailscale cert/key created"
    else
      echo_fail "Failed creating tailscale certificates"
    fi
  fi

  tailscale status

  echo_success "Your tailscale node ${CURRENT_HOST} is up & running"
else
  echo_warning "Skipping tailscale setup. Issued by TS_UP environment variable."
fi

exec "$@"