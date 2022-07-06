# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}

scribe service is dead:
  compose.dead:
    - name: {{ scribe.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if scribe.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ scribe.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if scribe.install.rootless %}
    - user: {{ scribe.lookup.user.name }}
{%- endif %}

scribe service is disabled:
  compose.disabled:
    - name: {{ scribe.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if scribe.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ scribe.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if scribe.install.rootless %}
    - user: {{ scribe.lookup.user.name }}
{%- endif %}
