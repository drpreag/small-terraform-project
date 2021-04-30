
Prerequisites:

1. In order to seed up vpc creation I did this:
    used ami image with IdX 5.1 installed (but had to fix manually few lines in config files...)

2. RDS is not created blank, but restored from snapshot (from Africa-demo vpc) with full IdX database,
    so there must be existing snapshot named: ${vpc_name}-db in order to make restore work

3. Only thing to do after terraform build new vpc is to set up in salt vpc role and server roles,