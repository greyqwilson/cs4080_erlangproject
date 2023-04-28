# cs4080_erlangproject


A demo can be run with the following sequence of commands in any terminal or command prompt that is running erlang's shell.
Lines prefixed with '%' are comments

%Spawn a process of sv to spawn a basic set of processes required to run the data store.
``SV = spawn(sv, init, []).``

%Spawn a client to access the data store
``Client = spawn(clientuser, init, [whereis(clientapN)]).``

%Send a message to the client to register with the system
``Client ! {self(), register, {testdude, 1111}}.``

%Login to the system with account created
``Client ! {self(), login, {testdude, 1111}}.``

%Add data to the account's store
``Client ! {add, amogus, {red, is, sus}}.``

%(Optional) Used to show processes running
``observer:start().``

%Tell warehouse to create a new storage_container
``warehouseN ! {self(), construct_st, cherry}.``

%Tell warehouse to create a new storage_container
``warehouseN ! {self(), construct_st, apple}.``

%Tell the cherry storage_container to shutdown
``exit(whereis(cherry), shutdown).``

%See what data is stored under the given name
``Client ! {show, amogus}.``

%Show all data stored in account
``Client ! {show_all}.``

%Tell apple storage_container to shutdown
``exit(whereis(apple), shutdown).``

%Show all data stored in account
``Client ! {show_all}.``
