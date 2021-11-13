#include "ip_centrale_dcc.h"
#include "ip_sept_segment.h"
#include "xgpio.h"


/*!
 * @function    init_GPIO
 * @abstract    fonction d'initialisation des peripherique GPIO.  
*/
void init_GPIO();


/*!
 * @function    write_sept_segment
 * @abstract    fonction d'écriture sur l'afficheur 7 segment sur les registre de l'IP sept segment.
 *
 * @param		data 	octet controllant les 8 cathodes MSB : DP CG CF CE CD CC CB CA : LSB.
 * @param 		anode 	variable indiquant sur quelle afficheur la valleur doit etre affiche.
 * 
*/
void write_sept_segment(unsigned char data,unsigned char anode); //


/*!
 * @function    ascii_to_sept_segment
 * @abstract    Code un caractere ASCII en un octet controlant les 8 cathodes.
 *
 * @param		valleur	caractere ASCII que l'on souhaite codé. 
*/
char ascii_to_sept_segment(unsigned char valleur); 


/*!
 * @function    DCCspeed_to_step
 * @abstract    Decode une vitesse du protocole DCC en une step.
 *
 * @param		valleur	vitesse que l'on souahite décodé. 
*/
char DCCspeed_to_step(unsigned char valleur);

/*!
 * @function    write_trame
 * @abstract    fonction d'écriture d'une trame DCC sur les registre de l'IP DCC.
*/
void write_trame(); 


/*!
 * @function    read_switch
 * @abstract    fonction de lecture des valleur des interrupteur.
*/
void read_switch(); 


/*!
 * @function    message_sept_segment
 * @abstract    fonction d'écriture sur les 8 afficheurs 7 segements.
*/
void message_sept_segment(); 


/*!
 * @function    write_led
 * @abstract    fonction d'écriture sur les leds.
 *
 * @param		data	valleur à écrire sur les leds. 
*/
void write_led(unsigned int data); 



XGpio led,button,sw;

int commande=0; //variable global contenant un ou deux octect de la prochaine commande à envoyer mise a jour par read_switch();

unsigned char addr=1; //addresse du train selectionner 
unsigned char tab_steps[5]={0,0,0,0,0}; // tableau permetant de stocker les steps de chaque train


//XPAR_IP_CENTRALE_DCC_V1_1_S00_AXI_BASEADDR
//XPAR_IP_SEPT_SEGMENT_0_S00_AXI_BASEADDR

int main () {
	init_GPIO();
	message_sept_segment();

	char button_C=0,button_U=0,button_D=0;

	char button_ancien_U=0,button_ancien_D=0;

	char tmp;
	while(1){

		tmp=XGpio_DiscreteRead(&button,2); //lecture de l'état des boutons
		button_U= (tmp>>2 &1); 
		button_C= (tmp>>1 &1);
		button_D= (tmp    &1);

		if(button_C == 1){ //Si le bouton Centrale est appuyé
			read_switch(); //mise a jour de commande

			if(((commande & 0xFF00) == 0) && ((commande>>6) == 1))//la commande est une vitesse
				tab_steps[addr]=DCCspeed_to_step(commande & 0x1F); //Mise a jour du tablea de step 

			write_trame(); //ecriture de la trame sur un les registre de l'IP DCC
			message_sept_segment(); //mise a jour du message affiché sur le 7 segment
			write_led(commande); //Ecriture de la commande sur les led
		}
		else {
			if(button_U == 1 && button_ancien_U == 0){ //Dtection d'un front montant du bouton UP
				addr++; //mise a jour de l'adresse (incrementation)
				if(addr==6) 
					addr=1;
				message_sept_segment(); //mise a jour de l'affichage sept segment
			}
			else{
				if(button_D == 1 && button_ancien_D == 0){ //Dtection d'un front montant du bouton DOWN
					addr--; //mise a jour de l'adresse (decrementation)
					if(addr==0)
						addr=5;
					message_sept_segment(); //mise a jour de l'affichage sept segment
				}
			}
		}

		button_ancien_U=button_U; //mise a jour des varriable permmetant stockant l'état des bouton UP et DOWN à l'isntant precedent
		button_ancien_D=button_D;

	}

}



void message_sept_segment(){
	write_sept_segment(ascii_to_sept_segment(addr+0x30),0); //Affichage du numero de locomotive sur l'afficheur 0
	write_sept_segment(ascii_to_sept_segment('L'),1); //Affichage de 'L' (pour locomotive)  sur l'afficheur 1
	write_sept_segment(ascii_to_sept_segment(tab_steps[addr]%10 + 0x30),2); //Affichage du chiffre des unité de la step de la locomotive selectionné sur l'afficheur 2
	write_sept_segment(ascii_to_sept_segment(tab_steps[addr]/10 + 0x30),3); //Affichage du chiffre des dizaine de la step de la locomotive selectionné sur l'afficheur 2
	write_sept_segment(ascii_to_sept_segment('S'),7); //Affichage de 'S' sur l'afficheur 7
	write_sept_segment(ascii_to_sept_segment('t'),6); //Affichage de 't' sur l'afficheur 6
	write_sept_segment(ascii_to_sept_segment('P'),4); //Affichage de 'P' sur l'afficheur 4

	if(tab_steps[addr]) //vitesse non null
		write_sept_segment(ascii_to_sept_segment('E'),5); //Affichage de 'E' sur l'afficheur 5 on affiche StEP xxLx
	else
		write_sept_segment(ascii_to_sept_segment('O'),5); //Affichage de 'O' sur l'afficheur 5 on affiche StOP xxLx

}


void read_switch(){
	commande = XGpio_DiscreteRead(&sw,1)&0xFFFF; //lecture des switch sur 16 bits
	if((commande & 0xFF00) != 0xDE00) //si different de F13 a F20 on a un seul octet
		commande>>=8; //on decale l'octet de poid fort sur l'octet de poid faible
}

void write_led(unsigned int data){
	XGpio_DiscreteWrite(&led,1,data);  
}


void init_GPIO(){
	XGpio_Initialize(&led,XPAR_GPIO_LED_DEVICE_ID); XGpio_SetDataDirection(&led,1,0x0);//LED(15 downto 0) output
	XGpio_Initialize(&sw,XPAR_GPIO_BOUTONS_DEVICE_ID); XGpio_SetDataDirection(&sw,1,0xFFFF);//SW(15 downto 0) input
	XGpio_Initialize(&button,XPAR_GPIO_BOUTONS_DEVICE_ID); XGpio_SetDataDirection(&button,2,0x7);//Button(2 downto 0) input
}


void write_sept_segment(unsigned char data,unsigned char anode){
	int tmp;
	//Si 0<= annode <= 3 on ecrit sur le slv_reg0
	//Sinon on ecrit sur le slv_reg1
 	if(anode<4){ //slv_reg0
		tmp = IP_SEPT_SEGMENT_mReadReg(XPAR_IP_SEPT_SEGMENT_0_S00_AXI_BASEADDR,IP_SEPT_SEGMENT_S00_AXI_SLV_REG0_OFFSET); //Lecture de la valleur du slv_reg0
		//(anode<<3) multiplie par 8 la valleur de anode
		tmp &= ~(0xFF<< (anode<<3)); //on met a 0 l'octet que l'on souhaite modifié 
		tmp |= data << (anode<<3); // on ecrit l'octet que l'on souhaite modifié 
		IP_SEPT_SEGMENT_mWriteReg(XPAR_IP_SEPT_SEGMENT_0_S00_AXI_BASEADDR,IP_SEPT_SEGMENT_S00_AXI_SLV_REG0_OFFSET,tmp);
	}
	else{ //slv_reg1
		anode-=4; 
		tmp = IP_SEPT_SEGMENT_mReadReg(XPAR_IP_SEPT_SEGMENT_0_S00_AXI_BASEADDR,IP_SEPT_SEGMENT_S00_AXI_SLV_REG1_OFFSET); //Lecture de la valleur du slv_reg1
		//(anode<<3) multiplie par 8 la valleur de anode
		tmp &= ~(0xFF<< (anode<<3) ); //on met a 0 l'octet que l'on souhaite modifié 
		tmp |= data << (anode<<3) ; // on ecrit l'octet que l'on souhaite modifié 
		IP_SEPT_SEGMENT_mWriteReg(XPAR_IP_SEPT_SEGMENT_0_S00_AXI_BASEADDR,IP_SEPT_SEGMENT_S00_AXI_SLV_REG1_OFFSET,tmp);
	}

}


void write_trame(){
    unsigned int reg0 = 0x3FFF; //ecriture du preambule sur le reg 0
	unsigned int reg1=0 ;

    reg0 <<= 9; 
	reg0 += addr & 0xFF ; //ecriture de l'adresse sur le reg 0
	reg0 <<= 9;


	if ((commande & 0xFF00) == 0xDE00){ //si la commande est sur 2 octet
		reg0 += (commande>>8 ) & 0xFF; //ecriture de l'octet de poid fort de commande sur le reg 0
		reg1 = commande & 0xFF; //ecriture de l'octet de poid faible de commande sur le reg 1
		reg1 <<= 9;
		reg1 += ( addr ^ (commande & 0xFF) ^ ((commande>>8 ) & 0xFF) ) & 0xFF; //ecriture de l'octet de controle sur le reg 1 
		reg1 <<=1;
		reg1 +=1; //bit de stop sur le reg 1 
	}
	else { //si la commande n'est pas sur 2 octet
		reg0 += commande & 0xFF;  //ecriture de l'octet de commande sur le reg 0
		reg1 += ( addr ^ commande) & 0xFF; //ecriture de l'octet de controle sur le reg 1 
		reg1 <<=1;
		reg1 +=1; //bit de stop sur le reg 1 
		reg1 <<= 9;
	}

	reg1 |= 1<<31; //flag indiquant a l'IP qu'une nouvelle trame est disponible 

	IP_CENTRALE_DCC_mWriteReg(XPAR_IP_CENTRALE_DCC_V1_1_S00_AXI_BASEADDR,IP_CENTRALE_DCC_S00_AXI_SLV_REG0_OFFSET,reg0);
	IP_CENTRALE_DCC_mWriteReg(XPAR_IP_CENTRALE_DCC_V1_1_S00_AXI_BASEADDR,IP_CENTRALE_DCC_S00_AXI_SLV_REG1_OFFSET,reg1);

}

char DCCspeed_to_step(unsigned char valleur){
	if(((valleur>>1) &0x7) == 0) //si les 3 bit S1 S2 S3 est nul il s'agit d'un StOP
		return 0;
	else //sinon il s'aggit d'une vitesse
		return ((valleur & 0xF)<<1) - 3 + (valleur>>4 &1) ;
}


char ascii_to_sept_segment(unsigned char valleur){

	switch ( valleur ){
								//	 _
	    case '0':  				//	| |
	    	return 0xC0;		//	|_|
								//
	    case '1':  				//	  |
	    	return 0xF9;		// 	  |
								//	 _
	    case '2':  				//	 _|
	    	return 0xA4;		//	|_
								//   _
	    case '3':  				//	 _|
	    	return 0xB0;		// 	 _|
								//
		case '4':  				//	|_|
			return 0x99;		//	  |
								//	 _
		case '5':  				//	|_
			return 0x92;		// 	 _|
								//	 _
		case '6':  				//	|_
			return 0x82;		//	|_|
								//	 _
		case '7':  				//	  |
			return 0xF8;		// 	  |
								//	 _
		case '8':  				//	|_|
			return 0x80;		//	|_|
								//	 _
		case '9':  				//	|_|
			return 0x90;		// 	 _|
								//
		case 'L':				//  |
			return 0xC7;		//	|_
								//	 _
		case 'S':  				//	|_
			return 0x92;		// 	 _|
								//
		case 't':  				//	|_
			return 0x87;		// 	|_
								//	 _
		case 'E':  				//	|_
			return 0x86;		// 	|_
								//	 _
		case 'P':  				//	|_|
			return 0x8C;		// 	|
								//	 _
	    case 'O':  				//	| |
	    	return 0xC0;		//	|_|
								//
	    case ' ':  				//
	    	return 0xFF;		//
		//	 _   	  _	  _
		//	|_ 	 |_	 |_  |_|
		// 	 _|  |_  |_  |

		//	 _   	  _	   _
		//	|_ 	 |_	 | |  |_|
		// 	 _|  |_  |_|  |

	    default:
	    	return 0xFF;

 	}

	return 0xFF;
}


