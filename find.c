void find (int A[],int low,int high, int n){

load ra;
if (low = 0){
    if (A[0]>= A[1] )
    {
        print;
    }
    
}

if (low = high){
    if (A[low]>= A[low-1] )
    {
        print;
    }
    return 
}

if (A[low-1]<=A[low] && A[low]>=A[low+1])
{
    print;
}

low= low +1;
find (A,low,high,n);
low = low - 1;
return
}
