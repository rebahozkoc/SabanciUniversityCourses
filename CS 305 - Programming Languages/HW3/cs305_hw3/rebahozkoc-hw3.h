#ifndef __HW3_H
#define __HW3_H

typedef enum { SUB, ADD, MUL, DIV } OpType;
typedef enum { INTEGER, REAL, STRING, ERROR } ExprType;

typedef struct LiteralNode
{
    ExprType type;
    union {
        int intValue;
        double realValue;
        char *stringValue;
    } value;
} LiteralNode;

typedef struct ExprNode
{
    int isConstant;
    int isTopLevel;
    struct ExprNode* left;
    struct ExprNode* right;
    OpType opType;
    int lineNum;
    ExprType type;
    union {
        int intValue;
        double realValue;
        char *stringValue;
        char *errorValue;
    } finalValue;

} ExprNode;

#endif