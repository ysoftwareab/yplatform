Flexible Docker entrypoints scripts
===================================

![Raphaël Pinson | © Camptocamp](/company/internal/team/image-thumb__362__contact-person/raphaelpinson_portrait_new.png "Raphaël Pinson | © Camptocamp")

##### Raphaël Pinson

22.03.2016

[](https://twitter.com/intent/tweet?text=Flexible%20Docker%20entrypoints%20scripts%20%40camptocamp&url=%0dhttps://www.camptocamp.com/en/news-events/flexible-docker-entrypoints-scripts)

[](https://www.facebook.com/sharer/sharer.php?u=https://www.camptocamp.com/en/news-events/flexible-docker-entrypoints-scripts)

When a [Docker](https://www.docker.com/) container starts, it calls its entrypoint command. Most of the time, this is the path to the service that should run in that container. It is however very common to run wrapping scripts in order to configure the container before starting the service:

    #!/bin/sh
    # Create user
    useradd myservice

    # Setup config
    sed -i "s/PASSWD/${SERVICE_PASSWORD}/g" /etc/myservice.conf

    # Start service
    exec /usr/sbin/myservice "$@"

Very often, this is achieved with a monolithic entrypoint script containing all the tuning options required for the container. This has several drawbacks:

-   inherited images need to fork that script in order to add tuning
-   the script is hard to maintain and cluttered
-   the script is written in one language (usually shell script)

At Camptocamp, while working on [our Dockerized Puppet stack](https://www.youtube.com/watch?v=onzP72ZMXcw) on Rancher, we have chosen to take a more flexible approach to entrypoint scripts by using a standard, static entrypoint script calling run-parts on a directory:

    #!/bin/bash

    DIR=/docker-entrypoint.d
    if [[ -d "$DIR" ]]; then
      /bin/run-parts --verbose "$DIR"
    fi

    exec "$@"

This brings us various advantages:

-   the entrypoint script is a standard in all our containers
-   entrypoint scripts are plugins that can be written in any language
-   inherited images can add to existing entrypoint scripts by simply adding to the /docker-entrypoint.d/ directory

Our Dockerfiles usually contain ONBUILD COPY statements to ease the deployment of additional entrypoint scripts. We can then set the entrypoint to call that generic script with the path to the service that needs to run, for example:

    COPY /docker-entrypoint.sh
    COPY /docker-entrypoint.d/* /docker-entrypoint.d/
    ONBUILD COPY /docker-entrypoint.d/* /docker-entrypoint.d/
    ENTRYPOINT ["/docker-entrypoint.sh", "/opt/puppetlabs/puppet/bin/mcollectived"]
    CMD ["--no-daemonize"]

Various examples of entrypoint scripts can be found [in our Docker projects](https://github.com/camptocamp?utf8=%E2%9C%93&query=docker-).
