#!/bin/bash
inst_ssl () { 
if netstat -nltp|grep 'stunnel4' 1>/dev/null 2>/dev/null;then
 [[ $(netstat -nltp|grep 'stunnel4'| wc -l) != '0' ]] && sslt=$(netstat -nplt |grep stunnel4 |awk {'print $4'} |awk -F ":" {'print $2'} |xargs) || sslt="\033[1;31mINDISPONIVEL"
    echo -e "\E[44;1;37m              GERENCIAR SSL TUNNEL               \E[0m"
    echo -e "\n\033[1;33mPORTAS\033[1;37m: \033[1;32m$sslt"
    echo ""
    echo -e "\033[1;37m[\033[1;31m1\033[1;37m] • \033[1;33mALTERAR PORTA SSL TUNNEL\033[0m"
    echo -e "\033[1;37m[\033[1;31m2\033[1;37m] • \033[1;33mREMOVER SSL TUNNEL\033[0m"
    echo -e "\033[1;37m[\033[1;31m0\033[1;37m] • \033[1;33mVOLTAR\033[0m"
    echo ""
    echo -ne "\033[1;32mOQUE DESEJA FAZER \033[1;33m?\033[1;37m "; read resposta
    echo ""
    if [[ "$resposta" = '1' ]]; then
    echo -ne "\033[1;32mQUAL PORTA DESEJA ULTILIZAR \033[1;33m?\033[1;37m "; read porta
    echo ""
 if [[ -z "$porta" ]]; then
  echo ""
  echo -e "\033[1;31mPorta invalida!"
  sleep 3
  clear
  fun_conexao  
 fi
 verif_ptrs $porta
 echo -e "\033[1;32mALTERANDO PORTA SSL TUNNEL!"
 var2=$(sed -n '9 p' /etc/stunnel/stunnel.conf)
 sed -i "s/$var2/accept = $porta/g" /etc/stunnel/stunnel.conf > /dev/null 2>&1
 echo ""
 fun_bar 'sleep 3'
 echo ""
 echo -e "\033[1;32mREINICIANDO SSL TUNNEL!\n"
 fun_bar 'service stunnel4 restart' '/etc/init.d/stunnel4 restart'
 echo ""
 netstat -nltp|grep 'stunnel4' > /dev/null && echo -e "\033[1;32mPORTA ALTERADA COM SUCESSO !" || echo -e "\033[1;31mERRO INESPERADO!"
 sleep 3.5s
 clear
 fun_conexao
 fi
 if [[ "$resposta" = '2' ]]; then
  echo -e "\033[1;32mREMOVENDO O  SSL TUNNEL !\033[0m"
  del_ssl () {
  service stunnel4 stop
  apt-get remove stunnel4 -y
  apt-get purge stunnel4 -y
  rm -rf /etc/stunnel/stunnel.conf
  rm -rf /etc/default/stunnel4
  rm -rf /etc/stunnel/stunnel.pem
  }
  echo ""
  fun_bar 'del_ssl'
  echo ""
  echo -e "\033[1;32mSSL TUNNEL REMOVIDO COM SUCESSO!\033[0m"
  sleep 3
  fun_conexao
 else
  echo -e "\033[1;31mRetornando...\033[0m"
  sleep 3
  fun_conexao
 fi
else
 clear
 echo -e "\E[44;1;37m           INSTALADOR SSL TUNNEL             \E[0m"
 echo -e "\n\033[1;33mVC ESTA PRESTES A INSTALAR O SSL TUNNEL !\033[0m"
 echo ""
 echo -ne "\033[1;32mDESEJA CONTINUAR \033[1;31m? \033[1;33m[s/n]:\033[1;37m "; read resposta
 if [[ "$resposta" = 's' ]]; then
 echo -e "\n\033[1;33mDEFINA UMA PORTA PARA O SSL TUNNEL !\033[0m"
 echo ""
 read -p "$(echo -e "\033[1;32mQUAL PORTA DESEJA UTILIZAR? \033[1;37m")" -e -i 3128 porta
 if [[ -z "$porta" ]]; then
  echo ""
  echo -e "\033[1;31mPorta invalida!"
  sleep 3
  clear
  fun_conexao
 fi
 verif_ptrs $porta
 echo -e "\n\033[1;32mINSTALANDO O SSL TUNNEL !\033[1;33m"
 echo ""
 fun_bar 'apt-get update -y' 'apt-get install stunnel4 -y'
 echo -e "\n\033[1;32mCONFIGURANDO O SSL TUNNEL !\033[0m"
 echo ""
 ssl_conf () {
    echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:22\naccept = ${porta}" > /etc/stunnel/stunnel.conf
    }
    fun_bar 'ssl_conf'
    echo -e "\n\033[1;32mCRIANDO CERTIFICADO !\033[0m"
    echo ""
    ssl_certif () {
    crt='US'
    openssl genrsa -out key.pem 2048 > /dev/null 2>&1
    (echo $crt; echo $crt; echo $crt; echo $crt; echo $crt; echo $crt; echo $crt)|openssl req -new -x509 -key key.pem -out cert.pem -days 1090 > /dev/null 2>&1
    cat cert.pem key.pem >> /etc/stunnel/stunnel.pem
    rm key.pem cert.pem > /dev/null 2>&1
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
    }
    fun_bar 'ssl_certif'
    echo -e "\n\033[1;32mINICIANDO O SSL TUNNEL !\033[0m"
    echo ""
    fun_finssl () {
    service stunnel4 restart
    service ssh restart
    /etc/init.d/stunnel4 restart
    }
    fun_bar 'fun_finssl' 'service stunnel4 restart'
    echo -e "\n\033[1;32mSSL TUNNEL INSTALADO COM SUCESSO !\033[1;31m PORTA: \033[1;33m$porta\033[0m"
    sleep 3
    clear
    fun_conexao
    else
    echo -e "\n\033[1;31mRetornando...\033[0m"
    sleep 3
    clear
    fun_conexao
    fi
