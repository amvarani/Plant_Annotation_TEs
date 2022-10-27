.. _ref-mgescan-installation:

MGEScan on Galaxy Installation
===============================================================================

MGEScan on Galaxy can be installed on a local machine or on the cloud e.g.
Amazon EC2. The local installation is for Ubuntu 14.04+ distribution. Others
(e.g. OpenSUSE, Fedora) are not verified.

.. tip:: approximate time: 20 minutes

Preparation
-------------------------------------------------------------------------------

There are required software to be installed prior to run MGEScan. You need to
install system packages with ``sudo`` command (admin ``root`` privilege is
required). ``virtualenv`` is used for Python package installation.

* ``root`` privilege to install packages with **sudo**

Quick Installation
-------------------------------------------------------------------------------

One-liner command provides a quick installation of required software and
configuration.

.. warning:: This one-liner installation script runs several commands without
             any further confirmation from you. If you'd like to verify each
             step, skip this quick installation and follow the installation
             instuctions below.

::

  curl -L https://raw.githubusercontent.com/MGEScan/mgescan/master/one-liner/ubuntu | bash

Start a Galaxy/MGEscan web server with a default port ``38080``.

::

  source ~/.mgescanrc
  cd $GALAXY_HOME
  nohup sh run.sh &

.. note:: RepeatMasker is not included.
.. note:: Default admin account is ``mgescan_admin@mgescan.com``. Sign up with
          this account name and your password.

Normal Installation
-------------------------------------------------------------------------------

Software for Python
-------------------------------------------------------------------------------

If ``virtualenv``, ``git``, and ``python-dev`` are available on your system,
you can skip this step.

**Ubuntu**

::

  sudo apt-get update
  sudo apt-get install python-virtualenv python-dev git -y

**Fedora**

::
 
  sudo yum update
  sudo yum install python-virtualenv python-devel git -y

Environment Variables
-------------------------------------------------------------------------------

MGEScan will be installed on a default directory ``$HOME/mgescan3``. You can
change it if you prefer other location to install MGEScan.

::

  export MGESCAN_HOME=$HOME/mgescan3
  export MGESCAN_SRC=$MGESCAN_HOME/src
  export GALAXY_HOME=$MGESCAN_HOME/galaxy
  export TRF_HOME=$MGESCAN_HOME/trf
  export RM_HOME=$MGESCAN_HOME/RepeatMasker
  export MGESCAN_VENV=$MGESCAN_HOME/virtualenv/mgescan

.. tip:: MGEScan on Galaxy uses version 3 in the naming like mgescan3.

Create a MGESCan start file ``.mgescanrc`` 

::

   cat <<EOF > $HOME/.mgescanrc
   export MGESCAN_HOME=\$HOME/mgescan3
   export MGESCAN_SRC=\$MGESCAN_HOME/src
   export GALAXY_HOME=\$MGESCAN_HOME/galaxy
   export TRF_HOME=\$MGESCAN_HOME/trf
   export RM_HOME=\$MGESCAN_HOME/RepeatMasker
   export MGESCAN_VENV=\$MGESCAN_HOME/virtualenv/mgescan
   EOF

Then include it to your startup file (i.e. ``.bash_profile``).

::

   echo "source ~/.mgescanrc" >> $HOME/.bash_profile

Create a main directory.

::

   source ~/.mgescanrc
   mkdir $MGESCAN_HOME


Software for MGEScan
-------------------------------------------------------------------------------

Galaxy Workflow, HMMER (3.1b1), EMBOSS Suite and TRF are required.
RepeatMasker is optional.

Galaxy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. tip:: Make sure that $MGESCAN_HOME is set by ``echo $MGESCAN_HOME`` command.
        If you don't see a path similar to ``/home/.../mgescan3/``, you have to
        define environment variables again.

From Github repository (source code):

::

        cd $MGESCAN_HOME
        git clone https://github.com/galaxyproject/galaxy/

HMMER and EMBOSS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you have ``HMMER`` and ``EMBOSS`` on your system, you can skip this step.

**Ubuntu**

::

        sudo apt-get install hmmer emboss -y

**Fedora**

* HMMER v3.1b2

::

        sudo yum install gcc -y
        wget ftp://selab.janelia.org/pub/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
        tar xvzf hmmer-3.1b2-linux-intel-x86_64.tar.gz
        cd  hmmer-3.1b2-linux-intel-x86_64
        ./configure
        make
        make check
        make install

* EMBOSS 6.6.0 (latest)

::

        wget ftp://emboss.open-bio.org/pub/EMBOSS/emboss-latest.tar.gz
        tar xvzf emboss-latest.tar.gz
        cd EMBOSS-*
        ./configure
        make
        make check
        make install

Open MPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Ubuntu**

::

        sudo apt-get install openmpi-bin libopenmpi-dev -y

Virtual Environments (virtualenv) for Python Packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is recommended to have an isolated environment for MGEScan Python
libraries. virtualenv creates a separated space for MGEScan, and issues from
dependencies and versions of Python libraries can be avoided. Note that you
have to be in the virtualenv of MGEScan before to run any MGEScan command line
tools. The following commands create a virtualenv for MGEScan and enable it on
your account.

::

  mkdir -p $MGESCAN_VENV
  virtualenv $MGESCAN_VENV
  source $MGESCAN_VENV/bin/activate
  echo "source $MGESCAN_VENV/bin/activate" >> ~/.bash_profile

.. note:: Skip the last line ``echo "source ..."``, if you'd like to enable
          ``mgescan`` virtualenv manually.


Tandem Repeats Finder (trf)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``trf`` is a single binary executable file to locate and display tandem repeats
in DNA sequences. MGEScan-LTR requires ``trf`` program.

::
 
   mkdir -p $TRF_HOME
   wget http://tandem.bu.edu/trf/downloads/trf407b.linux64 -P $TRF_HOME
   
RepeatMasker (Optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RepeatMasker is a program that screens DNA sequences for interspersed repeats
and low complexity DNA sequences. MGEScan-LTR has an option to use
RepeatMasker.

::

   mkdir $RM_HOME
   wget http://www.repeatmasker.org/RepeatMasker-open-4-0-5.tar.gz
   tar xvzf RepeatMasker-open-4-0-5.tar.gz
   mv RepeatMasker/* $RM_HOME
   ln -s $RM_HOME/RepeatMasker $MGESCAN_VENV/bin/
  
MGEScan Installation
-------------------------------------------------------------------------------

MGEScan can be installed from Github repository (source code):

::

  cd $MGESCAN_HOME
  git clone https://github.com/MGEScan/mgescan.git
  ln -s mgescan src 
  cd $MGESCAN_SRC
  python setup.py install

Configuration
-------------------------------------------------------------------------------

Virtual Environments (virtualenv)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Make sure you have loaded your virtual environment for MGEScan by:

::

  source $MGESCAN_VENV/bin/activate

You will see ``(mgescan)`` label on your prompt.

Galaxy Configurations for MGEScan
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

MGEScan github repository contains codes and toolkits for MGEScan on Galaxy.
Prior to run a Galaxy Workflow web server, the codes and toolkits should be
installed in the ``galaxy`` main directory.

::

  cp -pr $MGESCAN_SRC/galaxy-modified/* $GALAXY_HOME

trf
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To run ``trf`` anywhere under ``mgescan`` virtualenv, we create a symlink in
the ``bin`` directory.

::

   ln -s $TRF_HOME/trf407b.linux64 $MGESCAN_VENV/bin/trf
   chmod 700 $MGESCAN_VENV/bin/trf

RepeatMasker
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RepeatMasker also requires configuration.

**Ubuntu**

::

   cd $RM_HOME
   $RM_HOME/configure

**Fedora**

::

   sudo yum install perl-Data-Dumper perl-Text-Soundex -y
   cd $RM_HOME
   $RM_HOME/configure

Outputs like so:

::

   RepeatMasker Configuration Program

   This program assists with the configuration of the
   RepeatMasker program.  The next set of screens will ask
   you to enter information pertaining to your system
   configuration.  At the end of the program your RepeatMasker
   installation will be ready to use.

    <PRESS ENTER TO CONTINUE>


Galaxy Admin User
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Declare your email address as a Galaxy admin user name.

::

   export GALAXY_ADMIN=mgescan_admin@mgescan.com

.. warning:: REPLACE ``mgescan_admin@mgescan.com`` with your email address. You
             also have to sign up Galaxy with this email address.

::

  sed -i "s/#admin_users = None/admin_users = $GALAXY_ADMIN/" $GALAXY_HOME/universe_wsgi.ini

Start Galaxy
-------------------------------------------------------------------------------

Simple ``run.sh`` script starts a Galaxy web server. First run of the script
takes some time to initialize database.

::

        cd $GALAXY_HOME
        nohup sh run.sh &

.. note:: Default port number : 38080 http://[IP ADDRESS]:38080




