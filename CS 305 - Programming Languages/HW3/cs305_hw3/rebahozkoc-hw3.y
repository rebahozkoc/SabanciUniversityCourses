%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "rebahozkoc-hw3.h"
void yyerror (const char *s) 
{}

int exprListSize = 0;
ExprNode **allExprList = NULL;

ExprNode* makeExpressionNode();
ExprNode* makeExpressionNodeFromLiteral(LiteralNode);
ExprNode* makeExpressionNodeOperation(ExprNode*, ExprNode*, OpType, int);
void addToExprList(ExprNode*);
ExprNode * assignOpr(ExprNode*);

%}

%union{
    int lineNum;
	LiteralNode literalNode;
	ExprNode * exprNodePtr;
}

%token <lineNum> tADD 
%token <lineNum> tSUB 
%token <lineNum> tMUL 
%token <lineNum> tDIV 
%token <literalNode> tSTRING 
%token <literalNode> tNUM 
%token tPRINT tGET tSET tFUNCTION tRETURN tIDENT tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC

%start prog

%type <exprNodePtr> expr
%type <exprNodePtr> operation

%%
prog:		'[' stmtlst ']'
;

stmtlst:	stmtlst stmt 
			|
;

stmt:		setStmt 
			| if 
			| print 
			| unaryOperation 
			| expr
			| returnStmt 
;

getExpr:	'[' tGET ',' tIDENT ',' '[' exprList ']' ']'
			| '[' tGET ',' tIDENT ',' '[' ']' ']'
			| '[' tGET ',' tIDENT ']'
;

setStmt:	'[' tSET ',' tIDENT ',' expr ']' 
;

if:			'[' tIF ',' condition ',' '[' stmtlst ']' ']'
			| '[' tIF ',' condition ',' '[' stmtlst ']' '[' stmtlst ']' ']'
;

print:		'[' tPRINT ',' expr ']'
;

operation:	'[' tADD ',' expr ',' expr ']' {$$ = makeExpressionNodeOperation($4, $6, ADD, $2);}
			| '[' tSUB ',' expr ',' expr ']' {$$ = makeExpressionNodeOperation($4, $6, SUB, $2);}
			| '[' tMUL ',' expr ',' expr ']' {$$ = makeExpressionNodeOperation($4, $6, MUL, $2);}
			| '[' tDIV ',' expr ',' expr ']' {$$ = makeExpressionNodeOperation($4, $6, DIV, $2);}
;	

unaryOperation: '[' tINC ',' tIDENT ']'
				| '[' tDEC ',' tIDENT ']'
;

expr:		tNUM {$$ = makeExpressionNodeFromLiteral($1);}
			| tSTRING  {$$ = makeExpressionNodeFromLiteral($1);}
			| getExpr {$$ = makeExpressionNode();}
			| function {$$ = makeExpressionNode();}
			| operation {$$ = assignOpr($1);}
			| condition {$$ = makeExpressionNode();}
;


function:	'[' tFUNCTION ',' '[' parametersList ']' ',' '[' stmtlst ']' ']'
			| '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'
;

condition:	'[' tEQUALITY ',' expr ',' expr ']'
			| '[' tGT ',' expr ',' expr ']'
			| '[' tLT ',' expr ',' expr ']'
			| '[' tGEQ ',' expr ',' expr ']'
			| '[' tLEQ ',' expr ',' expr ']'
;

returnStmt:	'[' tRETURN ',' expr ']'
			| '[' tRETURN ']'
;

parametersList: parametersList ',' tIDENT 
			| tIDENT
;

exprList:	exprList ',' expr 
			| expr
;


%%

ExprNode * makeExpressionNode(){
	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
	newNode->isConstant = 0;
	newNode->left = 0;
	newNode->right = 0;
	newNode->isTopLevel = 0;
	return newNode;
}

ExprNode* makeExpressionNodeFromLiteral(LiteralNode literalNode){
	// This creates a exprnode with type const Expr i.e. left, right is null and isConstant is true
	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
	newNode->isConstant = 1;
	newNode->left = 0;
	newNode->right = 0;
	ExprType exprType = literalNode.type;
	if (exprType == STRING){
		newNode->finalValue.stringValue = malloc(strlen(literalNode.value.stringValue) + 1);
		strcpy(newNode->finalValue.stringValue, literalNode.value.stringValue); 
		newNode->type = STRING;
	}
	if (exprType == REAL){
		newNode->finalValue.realValue = literalNode.value.realValue;
		newNode->type = REAL;
	}
	if (exprType == INTEGER){
		newNode->finalValue.intValue = literalNode.value.intValue;
		newNode->type = INTEGER;
	}

	return newNode;
}

ExprNode * assignOpr(ExprNode* opr){
	return opr;
}

char *repeat_string(const char *str, int n) {
    if (n <= 0) {
        return NULL;
    }

    size_t len = strlen(str);
    size_t new_len = len * n;

    char *new_str = (char *)malloc((new_len + 1) * sizeof(char));

    if (new_str == NULL) {
        printf("Memory allocation failed.\n");
        return NULL;
    }
	int i;
    for (i = 0; i < n; i++) {
        memcpy(new_str + (i * len), str, len);
    }

    new_str[new_len] = '\0';
    return new_str;
}


void evalExpr(ExprNode* exprNode){
	if (exprNode->isConstant == 1){
		return;
	}
	if (exprNode->left != 0){
		evalExpr(exprNode->left);
	}
	if (exprNode->right != 0){
		evalExpr(exprNode->right);
	}
	if ((exprNode->left != 0) && (exprNode->right != 0) && (exprNode->left->isConstant == 1) && (exprNode->right->isConstant == 1)){
		ExprType leftType = exprNode->left->type;
		ExprType rightType = exprNode->right->type;
		int lineNum = exprNode->lineNum;

		if (exprNode->opType == ADD){
			// String addition
			if((leftType == STRING  && rightType != STRING) || (leftType != STRING  && rightType == STRING)){
				char * result;
				asprintf(&result, "Type mismatch on %d\n", lineNum);
				exprNode->finalValue.errorValue = result;				
				exprNode->isConstant = 1;
				exprNode->type = ERROR;
			}else{
				// I need to mark the sub expressions not toplevel here
				// because if the current node has a mismatch then the children become toplevel
				exprNode->right->isTopLevel = 0;
				exprNode->left->isTopLevel = 0;

			}
			if(leftType == STRING && rightType == STRING){
				char *result = (char *)malloc(strlen(exprNode->left->finalValue.stringValue) + strlen(exprNode->right->finalValue.stringValue) + 1);
				strcpy(result, exprNode->left->finalValue.stringValue);
				strcat(result, exprNode->right->finalValue.stringValue);
				exprNode->finalValue.stringValue = result;
				exprNode->type = STRING;
				exprNode->isConstant = 1;
			}

			// Real addition
			if(leftType == REAL && rightType == REAL){
				double result = exprNode->left->finalValue.realValue + exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			if(leftType == INTEGER && rightType == REAL){
				double result = exprNode->left->finalValue.intValue + exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			if(leftType == REAL && rightType == INTEGER){
				double result = exprNode->left->finalValue.realValue + exprNode->right->finalValue.intValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			// Integer addition
			if(leftType == INTEGER && rightType == INTEGER){
				int result = exprNode->left->finalValue.intValue + exprNode->right->finalValue.intValue;
				exprNode->finalValue.intValue = result;
				exprNode->type = INTEGER;
				exprNode->isConstant = 1;
			}
		}


		if (exprNode->opType == SUB){
			if(leftType == STRING || rightType == STRING){
				char * result;
				asprintf(&result, "Type mismatch on %d\n", lineNum);
				exprNode->finalValue.errorValue = result;				
				exprNode->isConstant = 1;
				exprNode->type = ERROR;
			}else{
				exprNode->right->isTopLevel = 0;
				exprNode->left->isTopLevel = 0;
			}

			// Real subtraction
			if(leftType == REAL && rightType == REAL){
				double result = exprNode->left->finalValue.realValue - exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			if(leftType == INTEGER && rightType == REAL){
				double result = exprNode->left->finalValue.intValue - exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}
						
			if(leftType == REAL && rightType == INTEGER){
				double result = exprNode->left->finalValue.realValue - exprNode->right->finalValue.intValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			// Integer subtraction
			if(leftType == INTEGER && rightType == INTEGER){
				int result = exprNode->left->finalValue.intValue - exprNode->right->finalValue.intValue;
				exprNode->finalValue.intValue = result;
				exprNode->type = INTEGER;
				exprNode->isConstant = 1;
			}
		}


		if (exprNode->opType == MUL){
			//String multiplication
			if ((leftType == STRING) || (leftType == REAL && rightType == STRING)){
				char * result;
				asprintf(&result, "Type mismatch on %d\n", lineNum);
				exprNode->finalValue.errorValue = result;				
				exprNode->isConstant = 1;
				exprNode->type = ERROR;
			}else{
				exprNode->right->isTopLevel = 0;
				exprNode->left->isTopLevel = 0;
			}

			if(leftType == INTEGER && rightType == STRING){
				char * result = repeat_string(exprNode->right->finalValue.stringValue, exprNode->left->finalValue.intValue);
				exprNode->finalValue.stringValue = result;
				exprNode->type = STRING;
				exprNode->isConstant = 1;
			}

			// real multiplication
			if(leftType == REAL && rightType == REAL){
				double result = exprNode->left->finalValue.realValue * exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			if(leftType == INTEGER && rightType == REAL){
				double result = exprNode->left->finalValue.intValue * exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}
						
			if(leftType == REAL && rightType == INTEGER){
				double result = exprNode->left->finalValue.realValue * exprNode->right->finalValue.intValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			// Integer multiplication
			if(leftType == INTEGER && rightType == INTEGER){
				int result = exprNode->left->finalValue.intValue * exprNode->right->finalValue.intValue;
				exprNode->finalValue.intValue = result;
				exprNode->type = INTEGER;
				exprNode->isConstant = 1;
			}
		}


		if (exprNode->opType == DIV){
			if ((leftType == STRING) || (rightType == STRING)){
				char * result;
				asprintf(&result, "Type mismatch on %d\n", lineNum);
				exprNode->finalValue.errorValue = result;				
				exprNode->isConstant = 1;
				exprNode->type = ERROR;
			}else{
				exprNode->right->isTopLevel = 0;
				exprNode->left->isTopLevel = 0;
			}

			// real division
			if(leftType == REAL && rightType == REAL){
				double result = exprNode->left->finalValue.realValue / exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			if(leftType == INTEGER && rightType == REAL){
				double result = exprNode->left->finalValue.intValue / exprNode->right->finalValue.realValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}
						
			if(leftType == REAL && rightType == INTEGER){
				double result = exprNode->left->finalValue.realValue / exprNode->right->finalValue.intValue;
				exprNode->finalValue.realValue = result;
				exprNode->type = REAL;
				exprNode->isConstant = 1;
			}

			// Integer division
			if(leftType == INTEGER && rightType == INTEGER){
				int result = exprNode->left->finalValue.intValue / exprNode->right->finalValue.intValue;
				exprNode->finalValue.intValue = result;
				exprNode->type = INTEGER;
				exprNode->isConstant = 1;
			}
		}
	}else{
		// The evaluation of left and right nodes did not yield const exprs then the current node is also not a const Expr
		exprNode->isConstant = 0;
	}
}

ExprNode* makeExpressionNodeOperation(ExprNode* left, ExprNode* right, OpType opType, int lineNum){
	ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
	// don't evaluate here
	// create a new node and assign left to left child and right to right child
	newNode->left = left;
	newNode->right = right;
	newNode->isConstant = 0;
	newNode->isTopLevel = 1;
	newNode->opType = opType;
	newNode->lineNum = lineNum;

	addToExprList(newNode);

	return newNode;
}

void addToExprList(ExprNode* exprNode){
	// If the list is uninitialized, initialize it and add the new element
    if (allExprList == NULL) {
        allExprList = (ExprNode **)malloc(sizeof(ExprNode *));
        if (allExprList == NULL) {
            printf("Memory allocation failed!\n");
            exit(1);
        }
        exprListSize = 1;
    }
    // Else, increase the size of the list by one and add the new element
    else {
        exprListSize++;
        allExprList = (ExprNode **)realloc(allExprList, exprListSize * sizeof(ExprNode *));
        if (allExprList == NULL) {
            printf("Memory reallocation failed!\n");
            exit(1);
        }
    }

    // Add the new element to the list
    allExprList[exprListSize - 1] = exprNode;
}


int extractLineNum(const char *inputStr){
	int result = 0;
	// The line contains Type mismatch output
	if(inputStr[0] == 'T'){
		sscanf(inputStr, "Type mismatch on %d", &result);
	}else{
		// The line contains Result of expression... output
		sscanf(inputStr, "Result of expression on %d", &result);
	}
	return result;
}


int string_compare(const void *a, const void *b) {
    // Cast the void pointers back to char pointers
    const char **str_a = (const char **)a;
    const char **str_b = (const char **)b;
	
    return extractLineNum(*str_a) >= extractLineNum(*str_b);
}



void printExprs(){
	int i = 0;
	for (; i < exprListSize; i++){
		evalExpr(allExprList[i]);
	}
	i = 0;
	int outputCount = 0;
	for (; i < exprListSize; i++){
		if ((allExprList[i]->isTopLevel && allExprList[i]->isConstant) || allExprList[i]->type == ERROR){
			outputCount += 1;
		}
	}
	const char* outputArray[outputCount];

	i = 0;
	int outputIndex = 0;
	for (; i < exprListSize; i++){
		if (allExprList[i]->isTopLevel && allExprList[i]->isConstant){
			if (allExprList[i]->type == REAL){
				char * result;
				asprintf(&result, "Result of expression on %d is (%.1f)\n", allExprList[i]->lineNum, allExprList[i]->finalValue.realValue);
				outputArray[outputIndex] = result;
				outputIndex += 1;
			}
			if (allExprList[i]->type == STRING){
				char * result;
				asprintf(&result, "Result of expression on %d is (%s)\n", allExprList[i]->lineNum, allExprList[i]->finalValue.stringValue);
				outputArray[outputIndex] = result;
				outputIndex += 1;
			}
			if (allExprList[i]->type == INTEGER){
				char * result;
				asprintf(&result, "Result of expression on %d is (%d)\n", allExprList[i]->lineNum, allExprList[i]->finalValue.intValue);
				outputArray[outputIndex] = result;
				outputIndex += 1;

			}
		}
		if(allExprList[i]->type == ERROR){
			char * result;
			asprintf(&result, allExprList[i]->finalValue.errorValue);
			outputArray[outputIndex] = result;
			outputIndex += 1;
		}
	}
	i = 0;
	qsort(outputArray, outputCount, sizeof(char *), string_compare);

	for (; i < outputCount; i++){
		printf(outputArray[i]);
	}
}

int main (){
	if (yyparse()) {
		// parse error
		printf("ERROR\n");
		return 1;
	}else {
		// successful parsing
		printExprs();
		return 0;
	}
}
