0) In case you're on Windows, please install WSL
    See https://msdn.microsoft.com/en-us/commandline/wsl/install_guide for details
    Perform all operations in bash console! (type "bash" at windows console)

1) Software required to perform release:
    - Maven 3.x
    - Java 7.x or 8.x
    - Svn command line client
    - Git command line client
        Don't forget to configure username and email
            git config --global user.name "John Doe"
            git config --global user.email johndoe@apache.org
    - GPG (already installed at most of *Nix)

    In case you're on Windows, please make sure all listed software installed under WSL.
    Type "bash" in Windows console and check each one. Use following commands to check:
        java -version
        git --version
        svn --version
        mvn -version
        gpg --version
    and use 'apt install ...' to install anything missing

2) Configuration required to perform release:
    - Create/Import your pgp secret key.
        In case you have no pgp key, please follow instructions from https://www.apache.org/dev/openpgp.html#generate-key

        Don't forget to add your public pgp key here to https://dist.apache.org/repos/dist/release/ignite/KEYS.txt
        https://dist.apache.org is a svn repository and can be updated using your apache credentials.

        Append you key using commands:

        gpg --list-sigs <keyname> >> KEYS.txt
        gpg --armor --export <keyname> >> KEYS.txt

    - Configure maven settings.xml (usually in /usr/share/maven/conf/ on Ubuntu):

        Add following and fill <username>, <password> and <gpg.*>

        <servers>
           <server>
               <id>apache.releases.https</id>
               <username>*</username> <!-- your apache username -->
               <password>*</password> <!-- your apache password -->
           </server>
        </servers>

        <profiles>
           <profile>
               <id>gpg</id>
               <properties>
                   <gpg.keyname>*</gpg.keyname> <!-- pgp keyname, eg. E38286D5 -->
                   <gpg.passphrase>*</gpg.passphrase> <!-- pgp passphrase -->
                   <gpg.useagent>false</gpg.useagent>
               </properties>
           </profile>
        </profiles>

3) Perform Vote steps and start Vote.
    Run all vote*.sh scripts
    Scripts are independent of each other and can be run in parallel, except *X_step_Y*.sh

    NOTE: some scripts may require sudo permissions, so you will be asked for sudo password

3.1) Perform Release Verification and send Release For Vote
    See https://cwiki.apache.org/confluence/display/IGNITE/Release+Process for details

4) Once Vote accepted, perform Release steps.
    Run all release*.sh scripts
    Scripts are independent of each other and can be run in parallel, except *X_step_Y*.sh

4.1) Close Vote
    See https://cwiki.apache.org/confluence/display/IGNITE/Release+Process for details
    Don't forget about Post-release steps

