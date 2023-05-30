// Reporte Creado Autom ticamente por Datapro 
// Fecha      : 29/05/2023 Hora: 12:35:52
// Aplicaci¢n : 01 Inventario
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
     oGenRep:cWhere  :=oGenRep:BuildWhere()          // Where Según RANGO/CRITERIO
     cSql   :=oGenRep:BuildSql() // Genera Código SQL

//BRWMAKER

     IF !ChkSql(cSql,@cMsg)      // Revisa Posible Ejecución SQL
        MensajeErr(cMsg,"Reporte <REPORTE>")
        Return .F.
     ENDIF

     IF !oGenRep:OutPut(.T.) // Verifica el Dispositivo de Salida Inicial
         RETURN .F.
     ENDIF

     oCursor:=OpenTable(cSql,.T.)

     IF oCursor:RecCount()=0
        MensajeErr("No fué posible Encontrar Información","Consulta Vacia Reporte <REPORTE>")
        oCursor:End()
        Return .F.
     ENDIF

     oCursor:GoTop()

     DEFINE FONT oFont1 NAME "ARIAL" SIZE 0,-10
     DEFINE FONT oFont2 NAME "ARIAL" SIZE 0,-10 BOLD

     REPORT oReport TITLE  "asientos x cuenta",;
            "Fecha: "+dtoc(Date())+" Hora: "+TIME();
            CAPTION "asientos x cuenta" ;
            FOOTER "Página: "+str(oReport:nPage,3)+" Registros: "+alltrim(str(nLineas,5))+" Usuario: "+oDp:cUsuario CENTER ;
            FONT oFont1,oFont2;
            PREVIEW

     oGenRep:SetDevice(oReport) // Asigna parámetros

     
     COLUMN TITLE "Código;Cuenta";
            DATA oCursor:MOC_CUENTA;
            SIZE 20;
            LEFT 

     COLUMN TITLE "Descripción";
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

     COLUMN TITLE "Descripción";
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
// En Cada Registro se puede Aplicar Fórmulas
// Es llamado por Skip()
*/
FUNCTION ONCHANGE()

   nLineas:=nLineas+1 // Es Posible Aplicar Fórmulas

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

     // Inicio del Línea
     DEFAULT nIni:=1

     cMemo :=STRTRAN(cMemo,CHR(10),"") // Convierte el Campo Memo en Arreglos
     aLines:=_VECTOR(cMemo,CHR(13))

     IF lData // Requiera la Primera Línea de Datos
        Return aLines[1]
     ENDIF

//   oReport:BackLine(1) // Retroceder una Línea
//   oReport:Newline()   // Adelanta una Línea
     FOR nFor := nIni TO LEN(aLines)
         oReport:StartLine()
         oReport:Say(nCol,aLines[nFor])
         oReport:EndLine()
     NEXT
     oReport:Newline()

RETURN ""

/*
// Inicio en Cada Página
*/
STATIC FUNCTION RepBitMap()

  DEFAULT oDp:cLogoBmp:="BITMAPS\LOGO.BMP"

  oReport:SayBitmap(.3,.3, oDp:cLogoBmp,.5,.5)

RETURN NIL
/*
oRun : objeto de Ejecución
*/

/*
 Encabezado Grupo : Código;Cuenta
*/
FUNCTION GROUP01()
   LOCAL cExp:="",uValue:=""
   cExp  :="Código;Cuenta: "
   uValue:=oCursor:MOC_CUENTA
   uValue:=cValtoChar(uValue)+" "+cValToChar(oCursor:CTA_DESCRI)
RETURN cExp+uValue

/*
 Finalizar Grupo : Código;Cuenta
*/
FUNCTION ENDGRP01()
   LOCAL cExp:="",uValue:="",cLines:=""
   cExp  :="Total Código;Cuenta:  "
   uValue:=oReport:aGroups[1]:cValue
   uValue:=uValue
   uValue:=cValtoChar(uValue)
   cLines:=ltrim(str(oReport:aGroups[1]:nCounter))
   cLines:=" ("+cLines+")"
RETURN cExp+uValue+cLines

// EOF 
