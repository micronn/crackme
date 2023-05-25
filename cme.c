#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

#define IDX_32CSND  16  /* index of our special segment */

extern DWORD WINAPI CheckDriver(void);
extern DWORD WINAPI CalculateKey(LPVOID *);

int main(void)
{
    CONTEXT ctx;
    DWORD code, result;
    HANDLE hThread;
    SetProcessAffinityMask(GetCurrentProcess(), 1);
    if (!CheckDriver()) {
        printf("Driver not loaded.\n");
        return EXIT_FAILURE;
    }
    code = GetTickCount();
    printf("Hey! Give me the key for the following code: %X\n", code);
    hThread = CreateThread(NULL, 0,
                            CalculateKey, (LPVOID)code,
                            CREATE_SUSPENDED, NULL);
    GetThreadContext(hThread, &ctx);
    ctx.SegCs = IDX_32CSND * 8 + 3;
    /* deliverately omit this, for more fun
     * if you really want to go this route, the calling
     * convention should be changed
    ctx.ContextFlags = CONTEXT_ALL;
    */
    SetThreadContext(hThread, &ctx);
    ResumeThread(hThread);
    WaitForSingleObject(hThread, INFINITE);
    GetExitCodeThread(hThread, &result);
    printf("? "); scanf("%x", &code);
    if (result == code) printf("Correct! You're the best!\n");
    else printf("Keep trying.\n");
    return EXIT_SUCCESS;
}