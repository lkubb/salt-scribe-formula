# vim: ft=sls

{#-
    Removes the configuration of the scribe containers
    and has a dependency on `scribe.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}

include:
  - {{ sls_service_clean }}

Scribe environment files are absent:
  file.absent:
    - names:
      - {{ scribe.lookup.paths.config_scribe }}
      - {{ scribe.lookup.paths.base | path_join(".saltcache.yml") }}
    - require:
      - sls: {{ sls_service_clean }}
