# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
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

Scribe paths are present:
  file.directory:
    - names:
      - {{ scribe.lookup.paths.base }}
    - user: {{ scribe.lookup.user.name }}
    - group: {{ scribe.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ scribe.lookup.user.name }}

Scribe repo is present:
  git.latest:
    - name: {{ scribe.lookup.repo }}
    - target: {{ scribe.lookup.paths.src }}
    - user: {{ scribe.lookup.user.name }}

Scribe compose file is managed:
  file.managed:
    - name: {{ scribe.lookup.paths.compose }}
    - source: {{ files_switch(['docker-compose.yml', 'docker-compose.yml.j2'],
                              lookup='Scribe compose file is present'
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
