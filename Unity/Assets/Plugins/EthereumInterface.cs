using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;
using AOT;

public class EthereumInterface : MonoBehaviour {
	
	public delegate void EthCallback(System.IntPtr ptr);

	[DllImport("__Internal")]
	private static extern void InitContract(string abi, string address);

	[DllImport("__Internal")]
	private static extern string GetCurrentAccount();

	[DllImport("__Internal")]
	private static extern string GetCurrentOpponents(EthCallback errorCallback, EthCallback successCallback);


	[DllImport("__Internal")]
	private static extern void SimpleMethod(EthCallback callback);

	void Start ()
	{
		InitContract ("[{\"constant\":false,\"inputs\":[{\"name\":\"opponent\",\"type\":\"address\"},{\"name\":\"card\",\"type\":\"uint8\"},{\"name\":\"password\",\"type\":\"string\"}],\"name\":\"Reveal\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"password\",\"type\":\"string\"},{\"name\":\"card\",\"type\":\"string\"}],\"name\":\"TestSha\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"opponent\",\"type\":\"address\"},{\"name\":\"card\",\"type\":\"uint8\"}],\"name\":\"AnswerGame\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"GetPlayersInteracting\",\"outputs\":[{\"name\":\"\",\"type\":\"address[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"opponent\",\"type\":\"address\"}],\"name\":\"GetGameState\",\"outputs\":[{\"name\":\"state\",\"type\":\"uint8\"},{\"name\":\"isPlayer\",\"type\":\"uint8\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"opponent\",\"type\":\"address\"},{\"name\":\"cardHash\",\"type\":\"bytes32\"}],\"name\":\"InitiateGame\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"GetPlayersWaitingForAnswer\",\"outputs\":[{\"name\":\"\",\"type\":\"address[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"GetPlayersWaitingForReveal\",\"outputs\":[{\"name\":\"\",\"type\":\"address[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"player1\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"player2\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"state\",\"type\":\"uint8\"}],\"name\":\"GameStateChanged\",\"type\":\"event\"}]", "0x680eec93545167219e7d248a44ac4017af1c2bab");
//		Debug.Log(GetCurrentAccount());
//		GetCurrentOpponents(OnCurrentOpponentsError, OnCurrentOpponentsSuccess);
	}

	public void CallSimpleMethod()
	{
		SimpleMethod(Callback);
	}

	public void CallGetCurrentOpponents()
	{
		GetCurrentOpponents(OnCurrentOpponentsError, OnCurrentOpponentsSuccess);
	}

	[MonoPInvokeCallback(typeof(EthCallback))]
	public static void OnCurrentOpponentsSuccess(System.IntPtr ptr)
	{
		string value = Marshal.PtrToStringAuto(ptr);
		Debug.LogFormat("OnCurrentOpponentsSuccess: {0}", value);
	}

	[MonoPInvokeCallback(typeof(EthCallback))]
	public static void OnCurrentOpponentsError(System.IntPtr ptr)
	{
		string value = Marshal.PtrToStringAuto(ptr);
		Debug.LogFormat("OnCurrentOpponentsError: {0}", value);
	}

	[MonoPInvokeCallback(typeof(EthCallback))]
	public static void Callback(System.IntPtr ptr)
	{
		string value = Marshal.PtrToStringAuto(ptr);
		Debug.Log("Managed string: " + value);
	}

}
