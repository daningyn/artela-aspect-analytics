
import {
    allocate,
    entryPoint,
    execute,
    IPostContractCallJP,
    PostContractCallInput,
    sys,
    uint8ArrayToString
} from "@artela/aspect-libs";

class Aspect implements IPostContractCallJP {

    isOwner(sender: Uint8Array): bool {
        return false;
    }

    /**
     * postContractCall is a join-point which will be invoked after a contract call has finished.
     *
     * @param input input to the current join point
     */
    postContractCall(input: PostContractCallInput): void {
        sys.require(input.call != null, 'No call data');
        const caller = uint8ArrayToString(input.call!.from);
        const receiver = uint8ArrayToString(input.call!.to);
        // Send the event here to track
    }
}

const aspect = new Aspect()
entryPoint.setAspect(aspect)

export { execute, allocate }

