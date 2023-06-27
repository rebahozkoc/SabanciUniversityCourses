parser: lex.yy.c parser.tab.c parser.tab.h
	gcc -o parser lex.yy.c parser.tab.c -lfl

lex.yy.c: scanner.flx
	flex scanner.flx

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

test:
	./parser < test_empty.JISP
	./parser < test_print.JISP
	./parser < test_return.JISP
	./parser < test_set.JISP
	./parser < test_inc_dec.JISP
	./parser < test_get.JISP
	./parser < test_operator.JISP
	./parser < test_func.JISP
	./parser < test_if.JISP
	./parser < test_condition.JISP
	./parser < test2.JISP
	
test2:
	/home/cerenyildirim/cs305golden/hw2v3 < test_empty.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_print.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_return.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_set.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_inc_dec.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_get.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_operator.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_func.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_if.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test_condition.JISP
	/home/cerenyildirim/cs305golden/hw2v3 < test2.JISP

	
	