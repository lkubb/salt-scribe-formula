# vim: ft=sls

{#-
    Starts the scribe container services
    and enables them at boot time.
    Has a dependency on `scribe.config`_.
#}

include:
  - .running
