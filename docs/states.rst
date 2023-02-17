Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``scribe``
^^^^^^^^^^
*Meta-state*.

This installs the scribe containers,
manages their configuration and starts their services.


``scribe.package``
^^^^^^^^^^^^^^^^^^
Installs the scribe containers only.
This includes creating systemd service units.


``scribe.config``
^^^^^^^^^^^^^^^^^
Manages the configuration of the scribe containers.
Has a dependency on `scribe.package`_.


``scribe.service``
^^^^^^^^^^^^^^^^^^
Starts the scribe container services
and enables them at boot time.
Has a dependency on `scribe.config`_.


``scribe.clean``
^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``scribe`` meta-state
in reverse order, i.e. stops the scribe services,
removes their configuration and then removes their containers.


``scribe.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the scribe containers
and the corresponding user account and service units.
Has a depency on `scribe.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``scribe.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the scribe containers
and has a dependency on `scribe.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``scribe.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Stops the scribe container services
and disables them at boot time.


