// Reporte Creado Autom�ticamente por Datapro 
// Fecha      : 29/05/2023 Hora: 12:35:52
// Aplicaci�n : 01 Inventario
// Tabla      : DPASIENTOS              

#include "dpxBase.CH"
// #include "DpxReport.ch"

PROCE MAIN(oGenRep)
     LOCAL cSql,oCursor,cMsg:="",oFont1,oFont2

     PRIVATE oReport,nLineas:=0

     IF oGenRep=NIL
       RETURN .F.
     ENDIF

     CursorWait()
/*
     // Aqui puede Personalizar la Consulta <QUERY>
     oGenRep:cSqlSelect    :="SELECT XCAMPO FROM DPASIENTOS"          // Nuevo Select
     oGenRep:cSqlInnerJoin:=" INNER JOIN TABLAB ON CAMPOA=CAMPOB " // Nuevo Inner Join
     oGenRep:cSqlOrderBy  :="ORDER BY XCAMPO"                      // Nuevo Order By
*/
     oGenRep:cWhere  :=oGenRep:BuildWhere()          // Where Seg�n RANGO/CRITERIO
     cSql   :=oGenRep:BuildSql() // Genera C�digo SQL

//BRWMAKER

     IF !ChkSql(cSql,@cMsg)      // Revisa Posible Ejecuci�n SQL
        MensajeErr(cMsg,"Reporte <REPORTE>")
        Return .F.
     ENDIF

     IF !oGenRep:OutPut(.T.) // Verifica el Dispositivo de Salida Inicial
         RETURN .F.
     ENDIF

     oCursor:=OpenTable(cSql,.T.)

     IF oCursor:RecCount()=0
        MensajeErr("No fu� posible Encontrar Informaci�n","Consulta Vacia Reporte <REPORTE>")
        oCursor:End()
        Return .F.
     ENDIF

     oCursor:GoTop()

     DEFINE FONT oFont1 NAME "ARIAL" SIZE 0,-10
     DEFINE FONT oFont2 NAME "ARIAL" SIZE 0,-10 BOLD

     REPORT oReport TITLE  "asientos x cuenta",;
            "Fecha: "+dtoc(Date())+" Hora: "+TIME();
            CAPTION "asientos x cuenta" ;
            FOOTER "P�gina: "+str(oReport:nPage,3)+" Registros: "+alltrim(str(nLineas,5))+" Usuario: "+oDp:cUsuario CENTER ;
            FONT oFont1,oFont2;
            PREVIEW

     oGenRep:SetDevice(oReport) // Asigna par�metros

     
     COLUMN TITLE "C�digo;Cuenta";
            DATA oCursor:MOC_CUENTA;
            SIZE 20;
            LEFT 

     COLUMN TITLE "Descripci�n";
            DATA oCursor:MOC_DESCRI;
            SIZE 120;
            LEFT 

     COLUMN TITLE "Documento";
            DATA oCursor:MOC_DOCUME;
            SIZE 20;
            LEFT 

     COLUMN TITLE "Fecha";
            DATA oCursor:MOC_FECHA;
            PICTURE "99/99/9999";
            SIZE 8;
            LEFT 

     COLUMN TITLE "Debe";
            DATA oCursor:MOC_MONTO;
            PICTURE "99,999,999,999,999,999,999,999.99";
            SIZE 24;
            RIGHT  

     COLUMN TITLE "Descripci�n";
            DATA oCursor:CTA_DESCRI;
            SIZE 40;
            LEFT 

     
      GROUP ON oCursor:MOC_CUENTA;
            FONT 2;
            HEADER GROUP01();
            FOOTER ENDGRP01()

     END REPORT

     oReport:bSkip:={||oCursor:DbSkip()}

     ACTIVATE REPORT oReport ;
              WHILE !oCursor:Eof();
              ON STARTGROUP oReport:NewLine();
              ON STARTPAGE  RepBitmap();
              ON CHANGE ONCHANGE()

     oGenRep:OutPut(.F.) // Verifica el Dispositivo de Salida Final

     oFont1:End()
     oFont2:End()

RETURN NIL

/*
// En Cada Registro se puede Aplicar F�rmulas
// Es llamado por Skip()
*/
FUNCTION ONCHANGE()

   nLineas:=nLineas+1 // Es Posible Aplicar F�rmulas

/*
   PrintMemo(cMemo,1,.T.,2)
// Si Desea Imprimir lineas Adicionales que no esten vacias
  
*/
   
 // PrintMemo(CAMPOMEMO,1,.F.,1) // Imprimir Campo Memo


RETURN .T.

/*
// Imprime Campos Memos
*/
FUNCTION PrintMemo(cMemo,nCol,lData,nIni)
     LOCAL nFor,aLines

     IF Empty(cMemo)
        RETURN ""
     ENDIF

     // Inicio del L�nea
     DEFAULT nIni:=1

     cMemo :=STRTRAN(cMemo,CHR(10),"") // Convierte el Campo Memo en Arreglos
     aLines:=_VECTOR(cMemo,CHR(13))

     IF lData // Requiera la Primera L�nea de Datos
        Return aLines[1]
     ENDIF

//   oReport:BackLine(1) // Retroceder una L�nea
//   oReport:Newline()   // Adelanta una L�nea
     FOR nFor := nIni TO LEN(aLines)
         oReport:StartLine()
         oReport:Say(nCol,aLines[nFor])
         oReport:EndLine()
     NEXT
     oReport:Newline()

RETURN ""

/*
// Inicio en Cada P�gina
*/
STATIC FUNCTION RepBitMap()

  DEFAULT oDp:cLogoBmp:="BITMAPS\LOGO.BMP"

  oReport:SayBitmap(.3,.3, oDp:cLogoBmp,.5,.5)

RETURN NIL
/*
oRun : objeto de Ejecuci�n
*/

/*
 Encabezado Grupo : C�digo;Cuenta
*/
FUNCTION GROUP01()
   LOCAL cExp:="",uValue:=""
   cExp  :="C�digo;Cuenta: "
   uValue:=oCursor:MOC_CUENTA
   uValue:=cValtoChar(uValue)+" "+cValToChar(oCursor:CTA_DESCRI)
RETURN cExp+uValue

/*
 Finalizar Grupo : C�digo;Cuenta
*/
FUNCTION ENDGRP01()
   LOCAL cExp:="",uValue:="",cLines:=""
   cExp  :="Total C�digo;Cuenta:  "
   uValue:=oReport:aGroups[1]:cValue
   uValue:=uValue
   uValue:=cValtoChar(uValue)
   cLines:=ltrim(str(oReport:aGroups[1]:nCounter))
   cLines:=" ("+cLines+")"
RETURN cExp+uValue+cLines

// EOF 
