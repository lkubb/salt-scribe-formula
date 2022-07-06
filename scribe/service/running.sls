# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}

include:
  - {{ sls_config_file }}

Scribe service is enabled:
  compose.enabled:
    - name: {{ scribe.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if scribe.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ scribe.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Scribe is installed
{%- if scribe.install.rootless %}
    - user: {{ scribe.lookup.user.name }}
{%- endif %}

Scribe service is running:
  compose.running:
    - name: {{ scribe.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if scribe.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ scribe.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if scribe.install.rootless %}
    - user: {{ scribe.lookup.user.name }}
{%- endif %}
    - watch:
      - Scribe is installed
