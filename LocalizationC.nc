#include <UserButton.h>
#include "Localization.h"
#include "printf.h"
#include <stdio.h>
module LocalizationC
{
	uses
	{
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as Timer0;
		interface Timer<TMilli> as Timer1;	
	}
	uses
	{
		interface Get<button_state_t>;
		interface Notify<button_state_t>;
	}
	uses
	{
		interface Packet;
		interface AMPacket;
		interface SplitControl as AMControl;
		interface Receive;
		interface AMSend;
		interface PacketTimeStamp<T32khz,uint32_t> as Tstamp;
	}
}

implementation
{

uint8_t	i,count2=0,count3=0,count4=0,count_timer=1;
uint8_t cnt=0;
message_t pkt;
bool radioBusy=FALSE;	
uint8_t Rec[20];
float weight[3];
uint32_t x[]={0,10000,20000};
uint32_t y[]={0,17320,0};
float Ynew, Xnew;
float densum, numsumx,numsumy; 

	event void Boot.booted()
	{
		call AMControl.start();
		call Notify.enable();
	}


	event void Notify.notify(button_state_t val)
	{
		printf("Start notify \n");
		call Timer0.startPeriodic(1000);
	}

	event void AMControl.startDone(error_t error)
	{
		// TODO Auto-generated method stub
		if(error!=SUCCESS)
			call AMControl.start();
		else
		{
			if(TOS_NODE_ID==1)
			{
				call Leds.led0On();
				call Leds.led1On();
				call Leds.led2On();
			}
			if(TOS_NODE_ID==2)
			{
				call Leds.led0On();
			}
			if(TOS_NODE_ID==3)
			{
				call Leds.led1On();
			}
			if(TOS_NODE_ID==4)
			{
				call Leds.led2On();
			}
		}

	}

	event void Timer0.fired()
	{
		
		
		if(TOS_NODE_ID!=1 && count_timer<=20)
		{	printf("Timer 0 fired \n");
			count_timer++;
			if (radioBusy==FALSE)
			
			{
				tmstmp_t* msg=call Packet.getPayload(&pkt, sizeof(tmstmp_t));
				msg->NodeId=TOS_NODE_ID;
				msg->Data=1;

				if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(tmstmp_t))==SUCCESS)
				{
					printf("Message broadcasted to headmote \n");
					radioBusy=TRUE;
				}

			}

		}

		if(count_timer>20)
			call Timer0.stop();

	}

	event void Timer1.fired()
	{
			
	}

	event void AMControl.stopDone(error_t error)
	{
		// TODO Auto-generated method stub
	}
	
	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		// TODO Auto-generated method stub
		radioBusy=FALSE;
		 
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		
		if(TOS_NODE_ID==1)
		{
			cnt++;
			if(len==sizeof(tmstmp_t))
			{
				tmstmp_t* incomePacket=(tmstmp_t*) payload;
				uint16_t node= incomePacket->NodeId;
				Rec[cnt]=node;
				
			}

			if(cnt>=20)
			{	
				call Timer0.stop();
				
				for(i=0;i<20;i++)
				{
					if(Rec[i]==2)
						count2++;
					if(Rec[i]==3)
						count3++;
					if(Rec[i]==4)
						count4++;
				}

				weight[0]=count2;
				weight[1]=count3;
				weight[2]=count4;
				densum=0;
				numsumx=0;
				numsumy=0;

				for(i=0;i<3;i++)
				{
					
					densum=densum+weight[i];
					numsumx=numsumx+(weight[i]*x[i]);
					numsumy=numsumy+(weight[i]*y[i]);
				}
				Xnew=(float)numsumx/(float)densum;
				Ynew=(float)numsumy/(float)densum;
				printf("X coordinate %d \n",Xnew);
				printf("Y coordinate %d \n",Ynew);

			}
		}

		
		return msg;

	}
}
