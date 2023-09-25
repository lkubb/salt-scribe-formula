# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Scribe environment files are managed:
  file.managed:
    - names:
      - {{ scribe.lookup.paths.config_scribe }}:
        - source: {{ files_switch(
                        ["scribe.env", "scribe.env.j2"],
                        config=scribe,
                        lookup="scribe environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: {{ scribe.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ scribe.lookup.user.name }}
    - require_in:
      - Scribe is installed
    - context:
        scribe: {{ scribe | json }}
