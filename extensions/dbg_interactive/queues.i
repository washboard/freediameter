/*********************************************************************************************************
* Software License Agreement (BSD License)                                                               *
* Author: Sebastien Decugis <sdecugis@nict.go.jp>							 *
*													 *
* Copyright (c) 2010, WIDE Project and NICT								 *
* All rights reserved.											 *
* 													 *
* Redistribution and use of this software in source and binary forms, with or without modification, are  *
* permitted provided that the following conditions are met:						 *
* 													 *
* * Redistributions of source code must retain the above 						 *
*   copyright notice, this list of conditions and the 							 *
*   following disclaimer.										 *
*    													 *
* * Redistributions in binary form must reproduce the above 						 *
*   copyright notice, this list of conditions and the 							 *
*   following disclaimer in the documentation and/or other						 *
*   materials provided with the distribution.								 *
* 													 *
* * Neither the name of the WIDE Project or NICT nor the 						 *
*   names of its contributors may be used to endorse or 						 *
*   promote products derived from this software without 						 *
*   specific prior written permission of WIDE Project and 						 *
*   NICT.												 *
* 													 *
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED *
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A *
* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR *
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 	 *
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 	 *
* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR *
* TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF   *
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.								 *
*********************************************************************************************************/

/* Do not include this directly, use dbg_interactive.i instead */

/****** FIFO QUEUES *********/

struct fifo {
};

%extend fifo {
	fifo() {
		struct fifo * q = NULL;
		int ret = fd_fifo_new(&q);
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
			return NULL;
		}
		return q;
	}
	~fifo() {
		struct fifo *q = self;
		fd_fifo_del(&q);
	}
	
	/* Move all elements to another queue */
	void move(struct fifo * to) {
		int ret = fd_fifo_move($self, to, NULL);
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
		}
	}
	
	/* Get the length of the queue (nb elements) */
	int length() {
		int l;
		int ret = fd_fifo_length ( $self, &l );
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
		}
		return l;
	}

	/* Is the threashold function useful here? TODO... */
	
	/* Post an item */
	void post(PyObject * item) {
		int ret;
		PyObject * i = item;
		
		Py_XINCREF(i);
		ret = fd_fifo_post($self, &i);
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
		}
	}
	
	/* Get (blocking) */
	PyObject * get() {
		int ret;
		PyObject * i = NULL;
		
		ret = fd_fifo_get($self, &i);
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
		}
		
		return i;
	}
	
	/* TryGet (non-blocking, returns None on empty queue) */
	PyObject * tryget() {
		int ret;
		PyObject * i = NULL;
		
		ret = fd_fifo_tryget($self, &i);
		if (ret == EWOULDBLOCK) {
			Py_XINCREF(Py_None);
			return Py_None;
		}
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
		}
		
		return i;
	}
	
	/* TimedGet (blocking for a while) */
	PyObject * timedget(long seconds) {
		int ret;
		PyObject * i = NULL;
		struct timespec ts;
		
		clock_gettime(CLOCK_REALTIME, &ts);
		ts.tv_sec += seconds;
		
		ret = fd_fifo_timedget($self, &i, &ts);
		if (ret == ETIMEDOUT) {
			Py_XINCREF(Py_None);
			return Py_None;
		}
		if (ret != 0) {
			DI_ERROR(ret, NULL, NULL);
		}
		
		return i;
	}
	
}		
	
	
	
	