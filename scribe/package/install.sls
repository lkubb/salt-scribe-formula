# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Scribe user account is present:
  user.present:
{%- for param, val in scribe.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ scribe.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

Scribe user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ scribe.lookup.user.name }}
    - enable: {{ scribe.install.rootless }}
    - require:
      - user: {{ scribe.lookup.user.name }}

Scribe paths are present:
  file.directory:
    - names:
      - {{ scribe.lookup.paths.base }}
    - user: {{ scribe.lookup.user.name }}
    - group: {{ scribe.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ scribe.lookup.user.name }}

{%- if scribe.install.podman_api %}

Scribe podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman
    - user: {{ scribe.lookup.user.name }}
    - require:
      - Scribe user session is initialized at boot

Scribe podman API is available:
  compose.systemd_service_running:
    - name: podman
    - user: {{ scribe.lookup.user.name }}
    - require:
      - Scribe user session is initialized at boot
{%- endif %}

Scribe repo is present:
  git.latest:
    - name: {{ scribe.lookup.repo }}
    - target: {{ scribe.lookup.paths.src }}
    - user: {{ scribe.lookup.user.name }}

Scribe compose file is managed:
  file.managed:
    - name: {{ scribe.lookup.paths.compose }}
    - source: {{ files_switch(["docker-compose.yml", "docker-compose.yml.j2"],
                              lookup="Scribe compose file is present"
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ scribe.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - makedirs: true
    - context:
        scribe: {{ scribe | json }}

Scribe is installed:
  compose.installed:
    - name: {{ scribe.lookup.paths.compose }}
{%- for param, val in scribe.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in scribe.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ scribe.lookup.paths.compose }}
      - git: {{ scribe.lookup.repo }}
{%- if scribe.install.rootless %}
    - user: {{ scribe.lookup.user.name }}
    - require:
      - user: {{ scribe.lookup.user.name }}
{%- endif %}

{%- if scribe.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Scribe:
{%-   if scribe.install.rootless %}
  compose.systemd_service_{{ "enabled" if scribe.install.autoupdate_service else "disabled" }}:
    - user: {{ scribe.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if scribe.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
