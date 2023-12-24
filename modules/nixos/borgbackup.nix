{ config, lib, pkgs, ... }:

{
  sops.secrets.borgbackup-passphrase = { };

  services.borgbackup.jobs.hetzner = {
    archiveBaseName = null; # hostname is not available to build archive name (cloud-init)
    compression = "zstd,3";
    encryption = { mode = "repokey-blake2"; passCommand = "cat ${config.sops.secrets.borgbackup-passphrase.path}"; };
    environment = {
      BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
      BORG_CACHE_DIR = "/var/cache/borg";
    };

    postHook = ''
      cat > /var/log/telegraf/borgbackup-job-hetzner.service <<EOF
      task,frequency=daily last_run=$(date +%s)i,state="$([[ $exitStatus == 0 ]] && echo ok || echo fail)"
      EOF
    '';
  };

  systemd.services.borgbackup-job-hetzner.serviceConfig = {
    CacheDirectory = "borg";
    ReadWritePaths = [ "/var/log/telegraf" ];
  };

  services.openssh.knownHosts = {
    # https://docs.hetzner.com/de/robot/storage-box/access/access-ssh-rsync-borg/#ssh-host-keys
    "hetzner-storage-box-ed25519" = {
      hostNames = [ "*.your-storagebox.de" "[*.your-storagebox.de]:23" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    };
    "hetzner-storage-box-rsa" = {
      hostNames = [ "*.your-storagebox.de" "[*.your-storagebox.de]:23" ];
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
    };
  };
}
