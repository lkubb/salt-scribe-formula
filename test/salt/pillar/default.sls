# -*- coding: utf-8 -*-
# vim: ft=yaml
---
scribe:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: scribe
      remove_orphans: true
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/scribe
      compose: docker-compose.yml
      config_scribe: scribe.env
      src: src
    user:
      groups: []
      home: null
      name: scribe
      shell: /usr/sbin/nologin
      uid: null
    repo: https://git.sr.ht/~edwardloveall/scribe
  install:
    rootless: true
    remove_all_data_for_sure: false
  config:
    app_domain: localhost:5183
    github_personal_access_token: null
    github_username: null
    lucky_env: production
    port: 5183
    secret_key_base: null

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://scribe/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   scribe-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      Scribe environment file is managed:
      - scribe.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
